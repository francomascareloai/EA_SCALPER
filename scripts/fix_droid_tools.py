"""Fix droid files to remove MCP tool references."""
import os
import re

droids_dir = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\.factory\droids"

# MCP patterns that cause "Unknown tool identifier" errors
bad_tools = [
    "context7___get-library-docs",
    "context7___resolve-library-id",
    "sequential-thinking___sequentialthinking",
    "perplexity-search___search",
    "exa___web_search_exa",
    "exa___get_code_context_exa",
    "brave-search___brave_web_search",
    "firecrawl___firecrawl_scrape",
    "firecrawl___firecrawl_search",
    "github___search_repositories",
    "github___search_code",
    "mql5-books___query_documents",
    "mql5-docs___query_documents",
    "memory___search_nodes",
    "memory___create_entities",
    "calculator___add",
    "calculator___mul",
    "calculator___div",
    "calculator___sqrt",
    "e2b___run_code",
    "FetchUrl",
    "sequential-thinking",
]

# Good tools that always work
good_tools = ["Read", "Edit", "Create", "Grep", "Glob", "Execute", "LS", "ApplyPatch", "WebSearch", "Task", "TodoWrite"]

fixed_count = 0
for filename in os.listdir(droids_dir):
    if filename.endswith(".md") and not filename.startswith("_"):
        filepath = os.path.join(droids_dir, filename)
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
        
        original = content
        
        # Find ALL tools lines and replace with single good one
        lines = content.split("\n")
        new_lines = []
        tools_found = False
        for line in lines:
            if line.startswith("tools: ["):
                if not tools_found:
                    # First tools line - replace with good tools
                    new_line = 'tools: [' + ', '.join(['"' + t + '"' for t in good_tools]) + ']'
                    new_lines.append(new_line)
                    tools_found = True
                # Skip any additional tools lines (duplicates)
            else:
                new_lines.append(line)
        
        new_content = "\n".join(new_lines)
        
        if new_content != original:
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(new_content)
            print(f"FIXED: {filename}")
            fixed_count += 1
        else:
            print(f"OK: {filename}")

print(f"\nTotal fixed: {fixed_count}")
