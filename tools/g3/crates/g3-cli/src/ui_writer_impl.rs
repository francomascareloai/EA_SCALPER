use g3_core::ui_writer::UiWriter;
use std::io::{self, Write};
use termimad::MadSkin;

/// Console implementation of UiWriter that prints to stdout
pub struct ConsoleUiWriter {
    current_tool_name: std::sync::Mutex<Option<String>>,
    current_tool_args: std::sync::Mutex<Vec<(String, String)>>,
    current_output_line: std::sync::Mutex<Option<String>>,
    output_line_printed: std::sync::Mutex<bool>,
}

impl ConsoleUiWriter {
    pub fn new() -> Self {
        Self {
            current_tool_name: std::sync::Mutex::new(None),
            current_tool_args: std::sync::Mutex::new(Vec::new()),
            current_output_line: std::sync::Mutex::new(None),
            output_line_printed: std::sync::Mutex::new(false),
        }
    }
}

impl UiWriter for ConsoleUiWriter {
    fn print(&self, message: &str) {
        print!("{}", message);
    }

    fn println(&self, message: &str) {
        println!("{}", message);
    }

    fn print_inline(&self, message: &str) {
        print!("{}", message);
        let _ = io::stdout().flush();
    }

    fn print_system_prompt(&self, prompt: &str) {
        println!("🔍 System Prompt:");
        println!("================");
        println!("{}", prompt);
        println!("================");
        println!();
    }

    fn print_context_status(&self, message: &str) {
        println!("{}", message);
    }

    fn print_context_thinning(&self, message: &str) {
        // Animated highlight for context thinning
        // Use bright cyan/green with a quick flash animation

        // Flash animation: print with bright background, then normal
        let frames = vec![
            "\x1b[1;97;46m", // Frame 1: Bold white on cyan background
            "\x1b[1;97;42m", // Frame 2: Bold white on green background
            "\x1b[1;96;40m", // Frame 3: Bold cyan on black background
        ];

        println!();

        // Quick flash animation
        for frame in &frames {
            print!("\r{} ✨ {} ✨\x1b[0m", frame, message);
            let _ = io::stdout().flush();
            std::thread::sleep(std::time::Duration::from_millis(80));
        }

        // Final display with bright cyan and sparkle emojis
        print!("\r\x1b[1;96m✨ {} ✨\x1b[0m", message);
        println!();

        // Add a subtle "success" indicator line
        println!("\x1b[2;36m   └─ Context optimized successfully\x1b[0m");
        println!();

        let _ = io::stdout().flush();
    }

    fn print_tool_header(&self, tool_name: &str, _tool_args: Option<&serde_json::Value>) {
        // Store the tool name and clear args for collection
        *self.current_tool_name.lock().unwrap() = Some(tool_name.to_string());
        self.current_tool_args.lock().unwrap().clear();
    }

    fn print_tool_arg(&self, key: &str, value: &str) {
        // Collect arguments instead of printing immediately
        // Filter out any keys that look like they might be agent message content
        // (e.g., keys that are suspiciously long or contain message-like content)
        let is_valid_arg_key = key.len() < 50
            && !key.contains('\n')
            && !key.contains("I'll")
            && !key.contains("Let me")
            && !key.contains("Here's")
            && !key.contains("I can");

        if is_valid_arg_key {
            self.current_tool_args
                .lock()
                .unwrap()
                .push((key.to_string(), value.to_string()));
        }
    }

    fn print_tool_output_header(&self) {
        println!();
        // Reset output_line_printed at the start of a new tool output
        // This ensures the header isn't cleared by update_tool_output_line
        *self.output_line_printed.lock().unwrap() = false;
        // Now print the tool header with the most important arg in bold green
        if let Some(tool_name) = self.current_tool_name.lock().unwrap().as_ref() {
            let args = self.current_tool_args.lock().unwrap();

            // Find the most important argument - prioritize file_path if available
            let important_arg = args
                .iter()
                .find(|(k, _)| k == "file_path")
                .or_else(|| args.iter().find(|(k, _)| k == "command" || k == "path"))
                .or_else(|| args.first());

            if let Some((_, value)) = important_arg {
                // For multi-line values, only show the first line
                let first_line = value.lines().next().unwrap_or("");

                // Truncate long values for display
                let display_value = if first_line.len() > 80 {
                    // Use char_indices to safely truncate at character boundary
                    let truncate_at = first_line
                        .char_indices()
                        .nth(77)
                        .map(|(i, _)| i)
                        .unwrap_or(first_line.len());
                    format!("{}...", &first_line[..truncate_at])
                } else {
                    first_line.to_string()
                };

                // Add range information for read_file tool calls
                let header_suffix = if tool_name == "read_file" {
                    // Check if start or end parameters are present
                    let has_start = args.iter().any(|(k, _)| k == "start");
                    let has_end = args.iter().any(|(k, _)| k == "end");

                    if has_start || has_end {
                        let start_val = args
                            .iter()
                            .find(|(k, _)| k == "start")
                            .map(|(_, v)| v.as_str())
                            .unwrap_or("0");
                        let end_val = args
                            .iter()
                            .find(|(k, _)| k == "end")
                            .map(|(_, v)| v.as_str())
                            .unwrap_or("end");
                        format!(" [{}..{}]", start_val, end_val)
                    } else {
                        String::new()
                    }
                } else {
                    String::new()
                };

                // Print with bold green tool name, purple (non-bold) for pipe and args
                println!(
                    "┌─\x1b[1;32m {}\x1b[0m\x1b[35m | {}{}\x1b[0m",
                    tool_name, display_value, header_suffix
                );
            } else {
                // Print with bold green formatting using ANSI escape codes
                println!("┌─\x1b[1;32m {}\x1b[0m", tool_name);
            }
        }
    }

    fn update_tool_output_line(&self, line: &str) {
        let mut current_line = self.current_output_line.lock().unwrap();
        let mut line_printed = self.output_line_printed.lock().unwrap();

        // If we've already printed a line, clear it first
        if *line_printed {
            // Move cursor up one line and clear it
            print!("\x1b[1A\x1b[2K");
        }

        // Print the new line
        println!("│ \x1b[2m{}\x1b[0m", line);
        let _ = io::stdout().flush();

        // Update state
        *current_line = Some(line.to_string());
        *line_printed = true;
    }

    fn print_tool_output_line(&self, line: &str) {
        // Skip the TODO list header line
        if line.starts_with("📝 TODO list:") {
            return;
        }
        println!("│ \x1b[2m{}\x1b[0m", line);
    }

    fn print_tool_output_summary(&self, count: usize) {
        println!(
            "│ \x1b[2m({} line{})\x1b[0m",
            count,
            if count == 1 { "" } else { "s" }
        );
    }

    fn print_tool_timing(&self, duration_str: &str) {
        // Parse the duration string to determine color
        // Format is like "1.5s", "500ms", "2m 30.0s"
        let color_code = if duration_str.ends_with("ms") {
            // Milliseconds - use default color (< 1s)
            ""
        } else if duration_str.contains('m') {
            // Contains minutes
            // Extract minutes value
            if let Some(m_pos) = duration_str.find('m') {
                if let Ok(minutes) = duration_str[..m_pos].trim().parse::<u32>() {
                    if minutes >= 5 {
                        "\x1b[31m" // Red for >= 5 minutes
                    } else {
                        "\x1b[38;5;208m" // Orange for >= 1 minute but < 5 minutes
                    }
                } else {
                    "" // Default color if parsing fails
                }
            } else {
                "" // Default color if 'm' not found (shouldn't happen)
            }
        } else if duration_str.ends_with('s') {
            // Seconds only
            if let Some(s_value) = duration_str.strip_suffix('s') {
                if let Ok(seconds) = s_value.trim().parse::<f64>() {
                    if seconds >= 1.0 {
                        "\x1b[33m" // Yellow for >= 1 second
                    } else {
                        "" // Default color for < 1 second
                    }
                } else {
                    "" // Default color if parsing fails
                }
            } else {
                "" // Default color
            }
        } else {
            // Milliseconds or other format - use default color
            ""
        };

        println!("└─ ⚡️ {}{}\x1b[0m", color_code, duration_str);
        println!();
        // Clear the stored tool info
        *self.current_tool_name.lock().unwrap() = None;
        self.current_tool_args.lock().unwrap().clear();
        *self.current_output_line.lock().unwrap() = None;
        *self.output_line_printed.lock().unwrap() = false;
    }

    fn print_agent_prompt(&self) {
        let _ = io::stdout().flush();
    }

    fn print_agent_response(&self, content: &str) {
        print!("{}", content);
        let _ = io::stdout().flush();
    }

    fn notify_sse_received(&self) {
        // No-op for console - we don't track SSEs in console mode
    }

    fn flush(&self) {
        let _ = io::stdout().flush();
    }

    fn prompt_user_yes_no(&self, message: &str) -> bool {
        print!("{} [y/N] ", message);
        let _ = io::stdout().flush();

        let mut input = String::new();
        if io::stdin().read_line(&mut input).is_ok() {
            let trimmed = input.trim().to_lowercase();
            trimmed == "y" || trimmed == "yes"
        } else {
            false
        }
    }

    fn prompt_user_choice(&self, message: &str, options: &[&str]) -> usize {
        println!("{} ", message);
        for (i, option) in options.iter().enumerate() {
            println!("  [{}] {}", i + 1, option);
        }
        print!("Select an option (1-{}): ", options.len());
        let _ = io::stdout().flush();

        loop {
            let mut input = String::new();
            if io::stdin().read_line(&mut input).is_ok() {
                if let Ok(choice) = input.trim().parse::<usize>() {
                    if choice > 0 && choice <= options.len() {
                        return choice - 1;
                    }
                }
            }
            print!("Invalid choice. Please select (1-{}): ", options.len());
            let _ = io::stdout().flush();
        }
    }

    fn print_final_output(&self, summary: &str) {
        // Show spinner while "formatting"
        let spinner_frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
        let message = "summarizing work done...";

        // Brief spinner animation (about 0.5 seconds)
        for i in 0..5 {
            let frame = spinner_frames[i % spinner_frames.len()];
            print!("\r\x1b[36m{} {}\x1b[0m", frame, message);
            let _ = io::stdout().flush();
            std::thread::sleep(std::time::Duration::from_millis(100));
        }

        // Clear the spinner line
        print!("\r\x1b[2K");
        let _ = io::stdout().flush();

        // Create a styled markdown skin
        let mut skin = MadSkin::default();
        // Customize colors for better terminal appearance
        skin.bold.set_fg(termimad::crossterm::style::Color::Green);
        skin.italic.set_fg(termimad::crossterm::style::Color::Cyan);
        skin.headers[0].set_fg(termimad::crossterm::style::Color::Magenta);
        skin.headers[1].set_fg(termimad::crossterm::style::Color::Magenta);
        skin.code_block.set_fg(termimad::crossterm::style::Color::Yellow);
        skin.inline_code.set_fg(termimad::crossterm::style::Color::Yellow);

        // Print a header separator
        println!("\x1b[1;35m━━━ Summary ━━━\x1b[0m");
        println!();

        // Render the markdown
        let rendered = skin.term_text(summary);
        print!("{}", rendered);

        // Print a footer separator
        println!();
        println!("\x1b[1;35m━━━━━━━━━━━━━━━\x1b[0m");
    }
}
