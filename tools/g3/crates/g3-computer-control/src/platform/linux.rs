use crate::ocr::{DefaultOCR, OCREngine};
use crate::{
    types::{Rect, TextLocation},
    ComputerController,
};
use anyhow::{Context, Result};
use async_trait::async_trait;

pub struct LinuxController {
    ocr_engine: Box<dyn OCREngine>,
    #[allow(dead_code)]
    ocr_name: String,
}

impl LinuxController {
    pub fn new() -> Result<Self> {
        let ocr = Box::new(DefaultOCR::new()?);
        let ocr_name = ocr.name().to_string();
        tracing::info!("Initialized Linux controller with OCR engine: {}", ocr_name);

        // Note: Linux computer control (mouse/screenshot/window focus) is intentionally minimal
        // for now. OCR from image files works via the configured OCR engine.
        Ok(Self {
            ocr_engine: ocr,
            ocr_name,
        })
    }
}

fn has_cmd(cmd: &str) -> bool {
    std::process::Command::new("which")
        .arg(cmd)
        .output()
        .is_ok_and(|o| o.status.success())
}

#[async_trait]
impl ComputerController for LinuxController {
    async fn take_screenshot(
        &self,
        _path: &str,
        _region: Option<Rect>,
        window_id: Option<&str>,
    ) -> Result<()> {
        // Keep API parity with macOS/windows: require window_id so callers are explicit about scope.
        if window_id.is_none() {
            anyhow::bail!("window_id is required. You must specify which window to capture (e.g., 'Firefox', 'Terminal', 'gedit'). Use list_windows to see available windows.");
        }

        anyhow::bail!(
            "Linux screenshot capture is not yet implemented in Rust.\n\
             If you only need OCR from image files, use `extract_text_from_image`.\n\
             (Future work: implement via X11/Wayland or external tools.)"
        )
    }

    async fn extract_text_from_screen(&self, _region: Rect, _window_id: &str) -> Result<String> {
        anyhow::bail!(
            "Linux screen OCR is not yet implemented (screenshot capture not available)."
        )
    }

    async fn extract_text_from_image(&self, path: &str) -> Result<String> {
        let locations = self.extract_text_with_locations(path).await?;
        let text = locations
            .into_iter()
            .map(|t| t.text)
            .collect::<Vec<_>>()
            .join(" ");
        Ok(text)
    }

    async fn extract_text_with_locations(&self, path: &str) -> Result<Vec<TextLocation>> {
        self.ocr_engine
            .extract_text_with_locations(path)
            .await
            .with_context(|| format!("OCR failed for image: {}", path))
    }

    async fn find_text_in_app(
        &self,
        _app_name: &str,
        _search_text: &str,
    ) -> Result<Option<TextLocation>> {
        anyhow::bail!("Linux find_text_in_app is not yet implemented.")
    }

    fn move_mouse(&self, x: i32, y: i32) -> Result<()> {
        if !has_cmd("xdotool") {
            anyhow::bail!(
                "`xdotool` is required for Linux mouse control (install via your package manager)."
            );
        }

        let status = std::process::Command::new("xdotool")
            .arg("mousemove")
            .arg(x.to_string())
            .arg(y.to_string())
            .status()
            .context("Failed to run xdotool mousemove")?;

        if !status.success() {
            anyhow::bail!("xdotool mousemove failed");
        }
        Ok(())
    }

    fn click_at(&self, x: i32, y: i32, app_name: Option<&str>) -> Result<()> {
        if !has_cmd("xdotool") {
            anyhow::bail!(
                "`xdotool` is required for Linux mouse control (install via your package manager)."
            );
        }

        if let Some(app) = app_name {
            // Best-effort focus (non-fatal if it fails).
            let _ = std::process::Command::new("xdotool")
                .arg("search")
                .arg("--name")
                .arg(app)
                .arg("windowactivate")
                .arg("--sync")
                .status();
        }

        let status = std::process::Command::new("xdotool")
            .arg("mousemove")
            .arg(x.to_string())
            .arg(y.to_string())
            .arg("click")
            .arg("1")
            .status()
            .context("Failed to run xdotool mousemove/click")?;

        if !status.success() {
            anyhow::bail!("xdotool click failed");
        }
        Ok(())
    }
}
