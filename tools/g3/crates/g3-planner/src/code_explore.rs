//! Code exploration module for analyzing codebases
//!
//! This module provides functions to explore and analyze codebases
//! for various programming languages, returning structured reports
//! about the code structure.

use std::path::Path;
use std::process::Command;

/// Main entry point for exploring a codebase at the given path.
/// Detects which languages are present and generates a comprehensive report.
pub fn explore_codebase(path: &str) -> String {
    let path = expand_tilde(path);
    let mut report = String::new();
    let mut languages_found = Vec::new();

    // Check for each language and add to report if found
    if has_rust_files(&path) {
        languages_found.push("Rust".to_string());
        report.push_str(&explore_rust(&path));
    }
    if has_java_files(&path) {
        languages_found.push("Java".to_string());
        report.push_str(&explore_java(&path));
    }
    if has_kotlin_files(&path) {
        languages_found.push("Kotlin".to_string());
        report.push_str(&explore_kotlin(&path));
    }
    if has_swift_files(&path) {
        languages_found.push("Swift".to_string());
        report.push_str(&explore_swift(&path));
    }
    if has_go_files(&path) {
        languages_found.push("Go".to_string());
        report.push_str(&explore_go(&path));
    }
    if has_python_files(&path) {
        languages_found.push("Python".to_string());
        report.push_str(&explore_python(&path));
    }
    if has_typescript_files(&path) {
        languages_found.push("TypeScript".to_string());
        report.push_str(&explore_typescript(&path));
    }
    if has_javascript_files(&path) {
        languages_found.push("JavaScript".to_string());
        report.push_str(&explore_javascript(&path));
    }
    if has_cpp_files(&path) {
        languages_found.push("C/C++".to_string());
        report.push_str(&explore_cpp(&path));
    }
    if has_markdown_files(&path) {
        languages_found.push("Markdown".to_string());
        report.push_str(&explore_markdown(&path));
    }
    if has_yaml_files(&path) {
        languages_found.push("YAML".to_string());
        report.push_str(&explore_yaml(&path));
    }
    if has_sql_files(&path) {
        languages_found.push("SQL".to_string());
        report.push_str(&explore_sql(&path));
    }
    if has_ruby_files(&path) {
        languages_found.push("Ruby".to_string());
        report.push_str(&explore_ruby(&path));
    }

    if languages_found.is_empty() {
        report.push_str("No recognized programming languages found in the codebase.\n");
    } else {
        let header = format!(
            "=== CODEBASE ANALYSIS ===\nLanguages detected: {}\n\n",
            languages_found.join(", ")
        );
        report = header + &report;
    }

    report
}

/// Expand tilde to home directory
fn expand_tilde(path: &str) -> String {
    if path.starts_with("~/") {
        if let Some(home) = std::env::var_os("HOME") {
            return path.replacen("~", &home.to_string_lossy(), 1);
        }
    }
    path.to_string()
}

/// Run a shell command and return its output
fn run_command(cmd: &str, working_dir: &str) -> String {
    let output = Command::new("sh")
        .arg("-c")
        .arg(cmd)
        .current_dir(working_dir)
        .output();

    match output {
        Ok(out) => {
            let stdout = String::from_utf8_lossy(&out.stdout);
            let stderr = String::from_utf8_lossy(&out.stderr);
            if !stdout.is_empty() {
                stdout.to_string()
            } else if !stderr.is_empty() {
                format!("(stderr): {}", stderr)
            } else {
                String::new()
            }
        }
        Err(e) => format!("Error running command: {}", e),
    }
}

/// Check if files with given extension exist
fn has_files_with_extension(path: &str, extension: &str) -> bool {
    let cmd = format!(
        "find . -name '.git' -prune -o -type f -name '*.{}' -print | head -1",
        extension
    );
    !run_command(&cmd, path).trim().is_empty()
}

// Language detection functions
fn has_rust_files(path: &str) -> bool {
    has_files_with_extension(path, "rs") || Path::new(path).join("Cargo.toml").exists()
}

fn has_java_files(path: &str) -> bool {
    has_files_with_extension(path, "java")
}

fn has_kotlin_files(path: &str) -> bool {
    has_files_with_extension(path, "kt") || has_files_with_extension(path, "kts")
}

fn has_swift_files(path: &str) -> bool {
    has_files_with_extension(path, "swift")
}

fn has_go_files(path: &str) -> bool {
    has_files_with_extension(path, "go")
}

fn has_python_files(path: &str) -> bool {
    has_files_with_extension(path, "py")
}

fn has_typescript_files(path: &str) -> bool {
    has_files_with_extension(path, "ts") || has_files_with_extension(path, "tsx")
}

fn has_javascript_files(path: &str) -> bool {
    has_files_with_extension(path, "js") || has_files_with_extension(path, "jsx")
}

fn has_cpp_files(path: &str) -> bool {
    has_files_with_extension(path, "cpp")
        || has_files_with_extension(path, "cc")
        || has_files_with_extension(path, "c")
        || has_files_with_extension(path, "h")
        || has_files_with_extension(path, "hpp")
}

fn has_markdown_files(path: &str) -> bool {
    has_files_with_extension(path, "md")
}

fn has_yaml_files(path: &str) -> bool {
    has_files_with_extension(path, "yaml") || has_files_with_extension(path, "yml")
}

fn has_sql_files(path: &str) -> bool {
    has_files_with_extension(path, "sql")
}

fn has_ruby_files(path: &str) -> bool {
    has_files_with_extension(path, "rb")
}

/// Explore Rust codebase
pub fn explore_rust(path: &str) -> String {
    let mut report = String::new();
    report.push_str("\n=== RUST ===\n\n");

    // File structure
    report.push_str("--- File Structure ---\n");
    let files = run_command(
        "rg --files -g '*.rs' . 2>/dev/null | grep -v '/target/' | sort | head -100",
        path,
    );
    report.push_str(&files);
    report.push('\n');

    // Dependencies (Cargo.toml)
    report.push_str("--- Dependencies (Cargo.toml) ---\n");
    let cargo = run_command("cat Cargo.toml 2>/dev/null | head -50", path);
    report.push_str(&cargo);
    report.push('\n');

    // Data structures
    report.push_str("--- Data Structures (Structs, Enums, Types) ---\n");
    let structs = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.rs' '^(pub )?(struct|enum|type|union) ' . 2>/dev/null | grep -v '/target/' | head -100"#,
        path,
    );
    report.push_str(&structs);
    report.push('\n');

    // Traits and implementations
    report.push_str("--- Traits & Implementations ---\n");
    let traits = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.rs' '^(pub )?trait |^impl ' . 2>/dev/null | grep -v '/target/' | head -100"#,
        path,
    );
    report.push_str(&traits);
    report.push('\n');

    // Public functions
    report.push_str("--- Public Functions ---\n");
    let funcs = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.rs' '^pub (async )?fn ' . 2>/dev/null | grep -v '/target/' | head -100"#,
        path,
    );
    report.push_str(&funcs);
    report.push('\n');

    report
}

/// Explore Java codebase
pub fn explore_java(path: &str) -> String {
    let mut report = String::new();
    report.push_str("\n=== JAVA ===\n\n");

    // File structure
    report.push_str("--- File Structure ---\n");
    let files = run_command(
        "rg --files -g '*.java' . 2>/dev/null | grep -v '/build/' | grep -v '/target/' | sort | head -100",
        path,
    );
    report.push_str(&files);
    report.push('\n');

    // Build files
    report.push_str("--- Build Configuration ---\n");
    let build = run_command(
        "cat pom.xml 2>/dev/null | head -50 || cat build.gradle 2>/dev/null | head -50",
        path,
    );
    report.push_str(&build);
    report.push('\n');

    // Classes and interfaces
    report.push_str("--- Classes & Interfaces ---\n");
    let classes = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.java' '^(public |private |protected )?(abstract )?(class|interface|enum|record) ' . 2>/dev/null | grep -v '/build/' | head -100"#,
        path,
    );
    report.push_str(&classes);
    report.push('\n');

    // Public methods
    report.push_str("--- Public Methods ---\n");
    let methods = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.java' '^\s+public .+\(' . 2>/dev/null | grep -v '/build/' | head -100"#,
        path,
    );
    report.push_str(&methods);
    report.push('\n');

    report
}

/// Explore Kotlin codebase
pub fn explore_kotlin(path: &str) -> String {
    let mut report = String::new();
    report.push_str("\n=== KOTLIN ===\n\n");

    // File structure
    report.push_str("--- File Structure ---\n");
    let files = run_command(
        "rg --files -g '*.kt' -g '*.kts' . 2>/dev/null | grep -v '/build/' | sort | head -100",
        path,
    );
    report.push_str(&files);
    report.push('\n');

    // Build files
    report.push_str("--- Build Configuration ---\n");
    let build = run_command(
        "cat build.gradle.kts 2>/dev/null | head -50 || cat build.gradle 2>/dev/null | head -50",
        path,
    );
    report.push_str(&build);
    report.push('\n');

    // Classes, objects, interfaces
    report.push_str("--- Classes, Objects & Interfaces ---\n");
    let classes = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.kt' '^(data |sealed |open |abstract )?(class|interface|object|enum class) ' . 2>/dev/null | grep -v '/build/' | head -100"#,
        path,
    );
    report.push_str(&classes);
    report.push('\n');

    // Functions
    report.push_str("--- Functions ---\n");
    let funcs = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.kt' '^(suspend |private |internal |public )?fun ' . 2>/dev/null | grep -v '/build/' | head -100"#,
        path,
    );
    report.push_str(&funcs);
    report.push('\n');

    report
}

/// Explore Swift codebase
pub fn explore_swift(path: &str) -> String {
    let mut report = String::new();
    report.push_str("\n=== SWIFT ===\n\n");

    // File structure
    report.push_str("--- File Structure ---\n");
    let files = run_command(
        "rg --files -g '*.swift' . 2>/dev/null | grep -v '/.build/' | sort | head -100",
        path,
    );
    report.push_str(&files);
    report.push('\n');

    // Package.swift
    report.push_str("--- Package Configuration ---\n");
    let pkg = run_command("cat Package.swift 2>/dev/null | head -50", path);
    report.push_str(&pkg);
    report.push('\n');

    // Classes, structs, protocols
    report.push_str("--- Types (Classes, Structs, Protocols, Enums) ---\n");
    let types = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.swift' '^(public |private |internal |open |final )?(class|struct|protocol|enum|actor) ' . 2>/dev/null | grep -v '/.build/' | head -100"#,
        path,
    );
    report.push_str(&types);
    report.push('\n');

    // Functions
    report.push_str("--- Functions ---\n");
    let funcs = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.swift' '^\s*(public |private |internal |open )?func ' . 2>/dev/null | grep -v '/.build/' | head -100"#,
        path,
    );
    report.push_str(&funcs);
    report.push('\n');

    report
}

/// Explore Go codebase
pub fn explore_go(path: &str) -> String {
    let mut report = String::new();
    report.push_str("\n=== GO ===\n\n");

    // File structure
    report.push_str("--- File Structure ---\n");
    let files = run_command(
        "rg --files -g '*.go' . 2>/dev/null | grep -v '/vendor/' | sort | head -100",
        path,
    );
    report.push_str(&files);
    report.push('\n');

    // go.mod
    report.push_str("--- Module Configuration ---\n");
    let gomod = run_command("cat go.mod 2>/dev/null | head -50", path);
    report.push_str(&gomod);
    report.push('\n');

    // Types (structs, interfaces)
    report.push_str("--- Types (Structs & Interfaces) ---\n");
    let types = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.go' '^type .+ (struct|interface)' . 2>/dev/null | grep -v '/vendor/' | head -100"#,
        path,
    );
    report.push_str(&types);
    report.push('\n');

    // Functions
    report.push_str("--- Functions ---\n");
    let funcs = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.go' '^func ' . 2>/dev/null | grep -v '/vendor/' | head -100"#,
        path,
    );
    report.push_str(&funcs);
    report.push('\n');

    report
}

/// Explore Python codebase
pub fn explore_python(path: &str) -> String {
    let mut report = String::new();
    report.push_str("\n=== PYTHON ===\n\n");

    // File structure
    report.push_str("--- File Structure ---\n");
    let files = run_command(
        "rg --files -g '*.py' . 2>/dev/null | grep -v '/__pycache__/' | grep -v '/venv/' | grep -v '/.venv/' | sort | head -100",
        path,
    );
    report.push_str(&files);
    report.push('\n');

    // Requirements/setup
    report.push_str("--- Dependencies ---\n");
    let deps = run_command(
        "cat requirements.txt 2>/dev/null | head -30 || cat pyproject.toml 2>/dev/null | head -50 || cat setup.py 2>/dev/null | head -30",
        path,
    );
    report.push_str(&deps);
    report.push('\n');

    // Classes
    report.push_str("--- Classes ---\n");
    let classes = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.py' '^class ' . 2>/dev/null | grep -v '/__pycache__/' | grep -v '/venv/' | head -100"#,
        path,
    );
    report.push_str(&classes);
    report.push('\n');

    // Functions
    report.push_str("--- Functions ---\n");
    let funcs = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.py' '^def |^async def ' . 2>/dev/null | grep -v '/__pycache__/' | grep -v '/venv/' | head -100"#,
        path,
    );
    report.push_str(&funcs);
    report.push('\n');

    report
}

/// Explore TypeScript codebase
pub fn explore_typescript(path: &str) -> String {
    let mut report = String::new();
    report.push_str("\n=== TYPESCRIPT ===\n\n");

    // File structure
    report.push_str("--- File Structure ---\n");
    let files = run_command(
        "rg --files -g '*.ts' -g '*.tsx' . 2>/dev/null | grep -v '/node_modules/' | grep -v '/dist/' | sort | head -100",
        path,
    );
    report.push_str(&files);
    report.push('\n');

    // package.json
    report.push_str("--- Package Configuration ---\n");
    let pkg = run_command("cat package.json 2>/dev/null | head -50", path);
    report.push_str(&pkg);
    report.push('\n');

    // Types, interfaces, classes
    report.push_str("--- Types, Interfaces & Classes ---\n");
    let types = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.ts' -g '*.tsx' '^export (type|interface|class|enum|abstract class) ' . 2>/dev/null | grep -v '/node_modules/' | head -100"#,
        path,
    );
    report.push_str(&types);
    report.push('\n');

    // Functions
    report.push_str("--- Exported Functions ---\n");
    let funcs = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.ts' -g '*.tsx' '^export (async )?function |^export const .+ = (async )?\(' . 2>/dev/null | grep -v '/node_modules/' | head -100"#,
        path,
    );
    report.push_str(&funcs);
    report.push('\n');

    report
}

/// Explore JavaScript codebase
pub fn explore_javascript(path: &str) -> String {
    let mut report = String::new();
    report.push_str("\n=== JAVASCRIPT ===\n\n");

    // File structure
    report.push_str("--- File Structure ---\n");
    let files = run_command(
        "rg --files -g '*.js' -g '*.jsx' . 2>/dev/null | grep -v '/node_modules/' | grep -v '/dist/' | sort | head -100",
        path,
    );
    report.push_str(&files);
    report.push('\n');

    // package.json
    report.push_str("--- Package Configuration ---\n");
    let pkg = run_command("cat package.json 2>/dev/null | head -50", path);
    report.push_str(&pkg);
    report.push('\n');

    // Classes
    report.push_str("--- Classes ---\n");
    let classes = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.js' -g '*.jsx' '^(export )?(default )?(class ) ' . 2>/dev/null | grep -v '/node_modules/' | head -100"#,
        path,
    );
    report.push_str(&classes);
    report.push('\n');

    // Functions
    report.push_str("--- Exported Functions ---\n");
    let funcs = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.js' -g '*.jsx' '^(export )?(async )?function |^module\.exports' . 2>/dev/null | grep -v '/node_modules/' | head -100"#,
        path,
    );
    report.push_str(&funcs);
    report.push('\n');

    report
}

/// Explore C/C++ codebase
pub fn explore_cpp(path: &str) -> String {
    let mut report = String::new();
    report.push_str("\n=== C/C++ ===\n\n");

    // File structure
    report.push_str("--- File Structure ---\n");
    let files = run_command(
        "rg --files -g '*.c' -g '*.cpp' -g '*.cc' -g '*.h' -g '*.hpp' . 2>/dev/null | grep -v '/build/' | sort | head -100",
        path,
    );
    report.push_str(&files);
    report.push('\n');

    // Build files
    report.push_str("--- Build Configuration ---\n");
    let build = run_command(
        "cat CMakeLists.txt 2>/dev/null | head -50 || cat Makefile 2>/dev/null | head -50",
        path,
    );
    report.push_str(&build);
    report.push('\n');

    // Classes and structs
    report.push_str("--- Classes & Structs ---\n");
    let classes = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.cpp' -g '*.cc' -g '*.h' -g '*.hpp' '^(class|struct|enum|union|typedef) ' . 2>/dev/null | grep -v '/build/' | head -100"#,
        path,
    );
    report.push_str(&classes);
    report.push('\n');

    // Functions (simplified pattern)
    report.push_str("--- Function Declarations ---\n");
    let funcs = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.h' -g '*.hpp' '^[a-zA-Z_][a-zA-Z0-9_<>: ]*\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\(' . 2>/dev/null | grep -v '/build/' | head -100"#,
        path,
    );
    report.push_str(&funcs);
    report.push('\n');

    report
}

/// Explore Markdown documentation
pub fn explore_markdown(path: &str) -> String {
    let mut report = String::new();
    report.push_str("\n=== MARKDOWN DOCUMENTATION ===\n\n");

    // File structure
    report.push_str("--- Documentation Files ---\n");
    let files = run_command(
        "rg --files -g '*.md' . 2>/dev/null | grep -v '/node_modules/' | grep -v '/vendor/' | sort | head -50",
        path,
    );
    report.push_str(&files);
    report.push('\n');

    // README content
    report.push_str("--- README Overview ---\n");
    let readme = run_command(
        "cat README.md 2>/dev/null | head -100 || cat readme.md 2>/dev/null | head -100",
        path,
    );
    report.push_str(&readme);
    report.push('\n');

    // Headers from all markdown files
    report.push_str("--- Document Headers ---\n");
    let headers = run_command(
        r#"rg --no-heading --line-number --with-filename -g '*.md' '^#{1,3} ' . 2>/dev/null | grep -v '/node_modules/' | head -100"#,
        path,
    );
    report.push_str(&headers);
    report.push('\n');

    report
}

/// Explore YAML configuration files
pub fn explore_yaml(path: &str) -> String {
    let mut report = String::new();
    report.push_str("\n=== YAML CONFIGURATION ===\n\n");

    // File structure
    report.push_str("--- YAML Files ---\n");
    let files = run_command(
        "rg --files -g '*.yaml' -g '*.yml' . 2>/dev/null | grep -v '/node_modules/' | grep -v '/vendor/' | sort | head -50",
        path,
    );
    report.push_str(&files);
    report.push('\n');

    // Top-level keys from YAML files
    report.push_str("--- Top-Level Keys ---\n");
    let keys = run_command(
        r#"rg --no-heading --line-number --with-filename -g '*.yaml' -g '*.yml' '^[a-zA-Z_][a-zA-Z0-9_-]*:' . 2>/dev/null | grep -v '/node_modules/' | head -100"#,
        path,
    );
    report.push_str(&keys);
    report.push('\n');

    report
}

/// Explore SQL files
pub fn explore_sql(path: &str) -> String {
    let mut report = String::new();
    report.push_str("\n=== SQL ===\n\n");

    // File structure
    report.push_str("--- SQL Files ---\n");
    let files = run_command(
        "rg --files -g '*.sql' . 2>/dev/null | sort | head -50",
        path,
    );
    report.push_str(&files);
    report.push('\n');

    // Tables
    report.push_str("--- Table Definitions ---\n");
    let tables = run_command(
        r#"rg --no-heading --line-number --with-filename -i -g '*.sql' 'CREATE TABLE' . 2>/dev/null | head -100"#,
        path,
    );
    report.push_str(&tables);
    report.push('\n');

    // Views and procedures
    report.push_str("--- Views & Procedures ---\n");
    let views = run_command(
        r#"rg --no-heading --line-number --with-filename -i -g '*.sql' 'CREATE (VIEW|PROCEDURE|FUNCTION)' . 2>/dev/null | head -100"#,
        path,
    );
    report.push_str(&views);
    report.push('\n');

    report
}

/// Explore Ruby codebase
pub fn explore_ruby(path: &str) -> String {
    let mut report = String::new();
    report.push_str("\n=== RUBY ===\n\n");

    // File structure
    report.push_str("--- File Structure ---\n");
    let files = run_command(
        "rg --files -g '*.rb' . 2>/dev/null | grep -v '/vendor/' | sort | head -100",
        path,
    );
    report.push_str(&files);
    report.push('\n');

    // Gemfile
    report.push_str("--- Dependencies (Gemfile) ---\n");
    let gemfile = run_command("cat Gemfile 2>/dev/null | head -50", path);
    report.push_str(&gemfile);
    report.push('\n');

    // Classes and modules
    report.push_str("--- Classes & Modules ---\n");
    let classes = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.rb' '^(class|module) ' . 2>/dev/null | grep -v '/vendor/' | head -100"#,
        path,
    );
    report.push_str(&classes);
    report.push('\n');

    // Methods
    report.push_str("--- Methods ---\n");
    let methods = run_command(
        r#"rg --no-heading --line-number --with-filename --max-filesize 500K -g '*.rb' '^\s*def ' . 2>/dev/null | grep -v '/vendor/' | head -100"#,
        path,
    );
    report.push_str(&methods);
    report.push('\n');

    report
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_expand_tilde() {
        let path = expand_tilde("~/test");
        assert!(!path.starts_with("~"));
    }

    #[test]
    fn test_explore_codebase_returns_string() {
        // Test with current directory
        let result = explore_codebase(".");
        assert!(!result.is_empty());
    }
}
