import os
import re
import hashlib
import shutil
from collections import defaultdict
import argparse

def normalize_name(filename):
    """
    Normalizes a filename to identify potential duplicates by creating a base name.
    e.g., 'KeyLevelsEA_Ulli (2).mq4' -> 'keylevelsulli'
    e.g., 'Key levels by leo_modified by Ulli.mq4' -> 'keylevelsleomodifiedulli'
    """
    name = os.path.splitext(filename)[0].lower()
    
    # Remove content in parentheses, e.g., (Bullforyou.com), (2)
    name = re.sub(r'\(.*?\)', '', name)
    
    # Define a list of common, non-descriptive words to remove
    stop_words = [
        'ea', 'ind', 'indicator', 'script', 'expert', 'advisor',
        'mod', 'modified', 'by', 'v', 'ver', 'version', 'build',
        'pro', 'new', 'full', 'mt4', 'mql4', 'ex4', 'mq4', 'rar', 'zip',
        'fix', 'fixed', 'test', 'final', 'clean', 'source', 'code'
    ]
    
    # Remove common separators and stop words
    # First, replace separators with spaces
    name = re.sub(r'[\s_.-]+', ' ', name)
    # Then, split into words, filter out stop words, and join
    words = [word for word in name.split() if word not in stop_words and not word.isdigit()]
    name = ''.join(words)
    
    return name

def get_md5(filepath):
    """Calculates the MD5 hash of a file."""
    hash_md5 = hashlib.md5()
    try:
        with open(filepath, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
    except (FileNotFoundError, IOError):
        return None
    return hash_md5.hexdigest()

def choose_best_file(files):
    """Chooses the best file to keep from a list of duplicates."""
    # Priority:
    # 1. No numeric suffix ' (d)'.
    # 2. Shorter filename.
    # 3. Alphabetical order as a tie-breaker.
    files.sort(key=lambda x: (
        bool(re.search(r'\s*\(\d+\)$', os.path.splitext(x)[0])), # False is better
        len(x),
        x
    ))
    return files[0]

def find_and_clean_duplicates(directory, simulate=True):
    """
    Finds and cleans duplicates using an aggressive name normalization and hash checking.
    """
    source_dir = directory
    backup_dir = os.path.join(source_dir, "Duplicates_Removed_Aggressive_MQL4")

    if not os.path.isdir(source_dir):
        print(f"Error: Directory not found at '{source_dir}'")
        return

    # 1. Group files by normalized name
    normalized_groups = defaultdict(list)
    all_mq4_files = [f for f in os.listdir(source_dir) if f.lower().endswith('.mq4')]
    
    for filename in all_mq4_files:
        norm_name = normalize_name(filename)
        if norm_name:
            normalized_groups[norm_name].append(filename)

    files_to_remove = set()
    total_groups_processed = 0
    
    # 2. Process each group
    for norm_name, file_list in normalized_groups.items():
        if len(file_list) < 2:
            continue # Not a potential duplicate group
        
        total_groups_processed += 1
        
        # 3. Create hash-based subgroups
        hash_subgroups = defaultdict(list)
        for filename in file_list:
            filepath = os.path.join(source_dir, filename)
            file_hash = get_md5(filepath)
            if file_hash:
                hash_subgroups[file_hash].append(filename)

        # 4. Decide which files to remove
        for duplicate_files in hash_subgroups.values():
            if len(duplicate_files) > 1:
                file_to_keep = choose_best_file(duplicate_files)
                for f in duplicate_files:
                    if f != file_to_keep:
                        files_to_remove.add(f)

    # 5. Perform cleanup
    if not files_to_remove:
        print("No new duplicates found with the aggressive strategy.")
        return

    if not os.path.exists(backup_dir) and not simulate:
        os.makedirs(backup_dir)

    total_size = 0
    print(f"--- Aggressive Cleanup Summary (Simulate: {simulate}) ---")
    print(f"Processed {total_groups_processed} groups based on normalized names.")
    print(f"Found {len(files_to_remove)} duplicate files to be removed:")

    sorted_removals = sorted(list(files_to_remove), key=str.lower)

    for filename in sorted_removals:
        file_path = os.path.join(source_dir, filename)
        try:
            file_size = os.path.getsize(file_path)
            total_size += file_size
            print(f"- {filename} ({file_size / 1024:.2f} KB)")
            
            if not simulate:
                shutil.move(file_path, os.path.join(backup_dir, filename))
        except FileNotFoundError:
            print(f"- WARNING: Could not find {filename} to remove.")
            continue
            
    print("\n" + "="*50)
    if simulate:
        print(f"SIMULATION: Would remove {len(files_to_remove)} files, saving {total_size / (1024*1024):.2f} MB.")
        print("Run with --execute to perform the cleanup.")
    else:
        print(f"SUCCESS: Removed {len(files_to_remove)} files, saving {total_size / (1024*1024):.2f} MB.")
        print(f"Duplicates moved to: {backup_dir}")
    print("="*50)

def main():
    parser = argparse.ArgumentParser(description="Aggressively clean up duplicate MQL4 files.")
    parser.add_argument("directory", type=str, help="The directory to clean up.")
    parser.add_argument("--execute", action="store_true", help="Actually perform the file cleanup. Default is simulation.")
    
    args = parser.parse_args()
    
    find_and_clean_duplicates(args.directory, simulate=not args.execute)

if __name__ == "__main__":
    main()