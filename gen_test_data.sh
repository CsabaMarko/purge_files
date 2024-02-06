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

# Generate test files
for Y in $(seq -w 2022 2023); do
  for M in $(seq -w 1 12); do
    for D in $(seq -w 1 28); do
      touch -m --date "$Y-$M-$D" "$target_dir/tmp_$Y-$M-$D.tmp";
    done
  done
done

Y=2024
for M in $(seq -w 1 2); do
  for D in $(seq -w 1 28); do
    touch -m --date "$Y-$M-$D" "$target_dir/tmp_$Y-$M-$D.tmp";
  done
done

# Print test file list
printf "Size\tLastModified\tPath\n"
find "$target_dir" -type f -printf "%s\t%TF\t%p\n" | sort --key=2

