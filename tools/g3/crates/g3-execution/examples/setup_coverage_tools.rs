use g3_execution::ensure_coverage_tools_installed;

fn main() -> anyhow::Result<()> {
    // Ensure coverage tools are installed
    let already_installed = ensure_coverage_tools_installed()?;

    if already_installed {
        println!("All coverage tools are already installed!");
    } else {
        println!("Coverage tools have been installed successfully!");
    }
    Ok(())
}
