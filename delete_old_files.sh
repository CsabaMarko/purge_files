#!/bin/bash

E_WRONG_ARGS=85

usage() {
  echo "Usage:"
  echo "$(basename "$0") target_dir"
}

# Test whether command-line argument is present (non-empty).
if [ -n "$1" ]
then
  target_dir=$1
else
  echo "ERROR: missing 1st argument" >&2
  usage
  exit $E_WRONG_ARGS
fi

echo "Before: (old files only)"
printf "Size\tLastModified\tPath\n"
find "$target_dir" -type f -mtime +365 -printf "%s\t%TF\t%p\n" | sort --key=2

echo "Deleting files..."
# Actual delete:
find "$target_dir" -type f -mtime +365 -print0 | xargs -0 -r rm

echo "After:"
printf "Size\tLastModified\tPath\n"
find "$target_dir" -type f -mtime +365 -printf "%s\t%TF\t%p\n" | sort --key=2
