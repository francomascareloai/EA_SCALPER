import os
import re
import shutil
import argparse
from collections import Counter

def classify_file(filepath):
    """Determines the type of an MQL4 file based on its content."""
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except (IOError, FileNotFoundError):
        return "unknown"

    # Use regex to avoid matching commented out functions
    has_on_tick = re.search(r'\bvoid\s+OnTick\s*\(', content)
    has_order_send = re.search(r'\bOrderSend\s*\(', content)
    has_on_calculate = re.search(r'\bint\s+OnCalculate\s*\(', content)
    has_set_index_buffer = re.search(r'\bSetIndexBuffer\s*\(', content)
    has_on_start = re.search(r'\bvoid\s+OnStart\s*\(', content)

    # Classification logic based on MQL4 function presence
    if has_on_tick and has_order_send:
        return "EA"
    if has_on_calculate or has_set_index_buffer:
        return "Indicator"
    if has_on_start and not (has_on_tick or has_on_calculate or has_set_index_buffer):
        return "Script"
    
    # Fallback for EAs that might use different trading functions
    if has_on_tick:
        return "EA"

    return "Unclassified"

def organize_mql4_files(source_dir, simulate=True):
    """Organizes MQL4 files from a source directory into category subdirectories."""
    base_target_dir = os.path.dirname(source_dir.rstrip('\/'))
    dest_paths = {
        "EA": os.path.join(base_target_dir, "EAs"),
        "Indicator": os.path.join(base_target_dir, "Indicators"),
        "Script": os.path.join(base_target_dir, "Scripts"),
        "Unclassified": os.path.join(base_target_dir, "Unclassified")
    }

    if not os.path.isdir(source_dir):
        print(f"Error: Source directory not found at '{source_dir}'")
        return

    if not simulate:
        for path in dest_paths.values():
            os.makedirs(path, exist_ok=True)

    all_mq4_files = [f for f in os.listdir(source_dir) if f.lower().endswith('.mq4') and os.path.isfile(os.path.join(source_dir, f))]
    
    classification_results = Counter()
    actions = []

    for filename in all_mq4_files:
        filepath = os.path.join(source_dir, filename)
        file_type = classify_file(filepath)
        classification_results[file_type] += 1
        
        if file_type != "unknown":
            dest_dir = dest_paths[file_type]
            actions.append((filepath, os.path.join(dest_dir, filename)))

    # Print summary and execute
    print(f"--- MQL4 File Classification Summary (Simulate: {simulate}) ---")
    print(f"Found {len(all_mq4_files)} .mq4 files to analyze.")
    print("\nClassification Counts:")
    for type, count in classification_results.items():
        print(f"- {type}: {count} files")
    print("\n" + "="*50)

    if simulate:
        print("SIMULATION MODE: No files will be moved.")
        print("Run with --execute to perform the organization.")
    else:
        print("EXECUTING file moves...")
        moved_count = 0
        for source_path, dest_path in actions:
            try:
                shutil.move(source_path, dest_path)
                moved_count += 1
            except (IOError, shutil.Error) as e:
                print(f"- ERROR moving {os.path.basename(source_path)}: {e}")
        print(f"\nSUCCESS: Moved {moved_count} files to their respective categories.")
    print("="*50)

def main():
    parser = argparse.ArgumentParser(description="Classify and organize MQL4 files based on content.")
    parser.add_argument("directory", type=str, help="The source directory containing .mq4 files.")
    parser.add_argument("--execute", action="store_true", help="Actually perform the file organization. Default is simulation.")
    
    args = parser.parse_args()
    
    organize_mql4_files(args.directory, simulate=not args.execute)

if __name__ == "__main__":
    main()