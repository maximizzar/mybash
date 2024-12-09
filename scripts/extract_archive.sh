#!/usr/bin/env bash

# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <archive_file>"
    exit 1
fi

# Get the file name from the arguments
archive_file="$1"

# Check if the file exists
if [ ! -f "$archive_file" ]; then
    echo "Error: File '$archive_file' not found!"
    exit 1
fi

check_tar() {
    if ! command -v tar &> /dev/null; then
        echo "Can't find tar!";
        exit 1;
    fi
}

# Function to extract archives based on file type
extract_archive() {
    case "$1" in
        *.tar.bz2)
            check_tar
            tar xvjf "$1" ;;
        *.tar.gz)
            check_tar
            tar xvzf "$1" ;;
        *.tar.xz)
            check_tar
            tar xvJf "$1" ;;
        *.tar)
            check_tar
            tar xvf "$1" ;;
        *.gz)
            if ! command -v gunzip &> /dev/null; then
                echo "Can't find gunzip!";
                exit 1;
            fi
            gunzip "$1" ;;
        *.bz2)
            if ! command -v bunzip2 &> /dev/null; then
                echo "Can't find bunzip2!";
                exit 1;
            fi
            bunzip2 "$1" ;;
        *.xz)
            if ! command -v unxz &> /dev/null; then
                echo "Can't find unxz!";
                exit 1;
            fi
            unxz "$1" ;;
        *.zip)
            if ! command -v unzip &> /dev/null; then
                echo "Can't find unzip!";
                exit 1;
            fi
            unzip "$1" ;;
        *.7z)
            if ! command -v 7z &> /dev/null; then
                echo "Can't find 7z!";
                exit 1;
            fi
            7z x "$1" ;;
        *.rar)
            if ! command -v rar &> /dev/null; then
                echo "Can't find rar!";
                exit 1;
            fi
            unrar x "$1" ;;
        *) echo "Unsupported file type: $1" ;;
    esac
}

# Extract the archive
extract_archive "$archive_file"
