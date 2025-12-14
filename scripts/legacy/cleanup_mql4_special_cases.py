import os
import re
import shutil
import argparse

def find_special_case_duplicates(directory):
    """
    Finds files that match complex duplicate patterns like name (1) (2).mq4 or name (2) (1).mq4.
    """
    # Regex to find file names ending with patterns like (number) or (number)(number)
    # e.g., file(1).mq4, file(1)(2).mq4, file (1) (2).mq4
    pattern = re.compile(r"(.+?)\s*(\(\d+\))+\.mq4$", re.IGNORECASE)
    
    files_to_remove = []
    
    all_files = [f for f in os.listdir(directory) if f.lower().endswith('.mq4')]
    
    for filename in all_files:
        match = pattern.match(filename)
        if match:
            base_name = match.group(1).strip()
            original_file_name = f"{base_name}.mq4"
            
            # Check if a non-numbered version exists
            if original_file_name in all_files:
                files_to_remove.append(filename)
            # If no direct original, it might be a duplicate of another numbered file
            # This logic can be complex, for now, we focus on simple cases where an original exists.

    # Also, find files that are simple duplicates like "file (1).mq4"
    simple_pattern = re.compile(r"(.+?)\s*\((\d+)\)\.mq4$", re.IGNORECASE)
    for filename in all_files:
        if filename in files_to_remove:
            continue # Already marked for removal
        
        match = simple_pattern.match(filename)
        if match:
            base_name = match.group(1).strip()
            original_file_name = f"{base_name}.mq4"
            if original_file_name in all_files:
                files_to_remove.append(filename)

    return list(set(files_to_remove)) # Return unique list

def cleanup_files(directory, simulate=True):
    """
    Moves the identified special case duplicate files to a backup folder.
    """
    files_to_remove = find_special_case_duplicates(directory)
    
    if not files_to_remove:
        print("No special case duplicate files found to clean up.")
        return

    backup_dir = os.path.join(directory, "Duplicates_Removed_Special_MQL4")
    if not os.path.exists(backup_dir) and not simulate:
        os.makedirs(backup_dir)
        
    total_size = 0
    
    print(f"--- Special Case Cleanup Summary (Simulate: {simulate}) ---")
    print(f"Found {len(files_to_remove)} files to be removed:")
    
    for filename in files_to_remove:
        file_path = os.path.join(directory, filename)
        file_size = os.path.getsize(file_path)
        total_size += file_size
        print(f"- {filename} ({file_size / 1024:.2f} KB)")
        
        if not simulate:
            shutil.move(file_path, os.path.join(backup_dir, filename))
            
    print("\\n" + "="*50)
    if simulate:
        print(f"SIMULATION: Would remove {len(files_to_remove)} files, saving {total_size / (1024*1024):.2f} MB.")
        print("Run with --execute to perform the cleanup.")
    else:
        print(f"SUCCESS: Removed {len(files_to_remove)} files, saving {total_size / (1024*1024):.2f} MB.")
        print(f"Duplicates moved to: {backup_dir}")
    print("="*50)

def main():
    parser = argparse.ArgumentParser(description="Clean up special case duplicate files in a directory.")
    parser.add_argument("directory", type=str, help="The directory to clean up.")
    parser.add_argument("--execute", action="store_true", help="Actually perform the file cleanup. Default is simulation.")
    
    args = parser.parse_args()
    
    source_dir = args.directory
    simulate = not args.execute

    if not os.path.isdir(source_dir):
        print(f"Error: Directory not found at '{source_dir}'")
        return
        
    cleanup_files(source_dir, simulate=simulate)

if __name__ == "__main__":
    # Example usage:
    # python cleanup_mql4_special_cases.py "C:/path/to/your/MQL4_folder/All_MQ4" --simulate
    # python cleanup_mql4_special_cases.py "C:/path/to/your/MQL4_folder/All_MQ4" --execute
    main()