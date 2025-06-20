#!/usr/bin/env python3

import os
import shutil
import hashlib
import argparse
from pathlib import Path

def calculate_file_hash(filepath):
    """Calculate MD5 hash of a file."""
    hash_md5 = hashlib.md5()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def safe_copy_and_delete(source_dir, dest_dir):
    """Copy files one by one and delete after verification."""
    
    # Convert to Path objects
    source_path = Path(source_dir)
    dest_path = Path(dest_dir)
    
    # Ensure destination directory exists
    dest_path.mkdir(parents=True, exist_ok=True)
    
    # Get list of files (not directories)
    files = [f for f in source_path.iterdir() if f.is_file()]
    total_files = len(files)
    
    print(f"Found {total_files} files to copy")
    
    for index, source_file in enumerate(files, 1):
        try:
            # Construct destination file path
            dest_file = dest_path / source_file.name
            
            print(f"\n[{index}/{total_files}] Copying {source_file.name}...")
            
            # Copy the file
            shutil.copy2(source_file, dest_file)
            
            # Verify the copy using hash comparison
            source_hash = calculate_file_hash(source_file)
            dest_hash = calculate_file_hash(dest_file)
            
            if source_hash == dest_hash:
                print(f"Hash verification successful for {source_file.name}")
                # Delete the source file
                source_file.unlink()
                print(f"Deleted {source_file.name}")
            else:
                print(f"WARNING: Hash mismatch for {source_file.name}!")
                print("File not deleted due to verification failure")
                
        except Exception as e:
            print(f"Error processing {source_file.name}: {str(e)}")

def main():
    parser = argparse.ArgumentParser(description='Safely copy files from source to destination and delete originals.')
    parser.add_argument('source_dir', help='Source directory path')
    parser.add_argument('dest_dir', help='Destination directory path')
    
    args = parser.parse_args()
    
    # Verify source directory exists
    if not os.path.exists(args.source_dir):
        print("Error: Source directory does not exist!")
        return
    
    print(f"Source directory: {args.source_dir}")
    print(f"Destination directory: {args.dest_dir}")
    
    # Ask for confirmation
    response = input("Proceed with copy and delete operation? (y/n): ")
    if response.lower() != 'y':
        print("Operation cancelled")
        return
    
    safe_copy_and_delete(args.source_dir, args.dest_dir)
    print("\nOperation completed!")

if __name__ == "__main__":
    main()

