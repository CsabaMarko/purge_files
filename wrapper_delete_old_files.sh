#!/bin/bash

DIR_APP=/opt/grandcnt/data/app-logs
MTIME_APP=366 # Delete files older than 366 days ~ 1 year

DIR_INI=/opt/grandcnt/data/initial
MTIME_INI=31 # Delete files older than 31 days ~ 1 month

normalize_var() {
  if [[ -z $1 ]] ; then
    echo 0
    return 0
  fi
  if [[ "$1" == "0" ]] || [[ "$1" == "n" ]] || [[ "$1" == "N" ]]
  then
    echo 0
    return 0
  fi
  echo 1
  return 1
}

VERBOSE=$(normalize_var "$VERBOSE")
DRY_RUN=$(normalize_var "$DRY_RUN")

start_timestamp=$(date --utc +%s)

usage() {
  echo "Usage:"
  echo $(basename "$0")
  echo
  echo "Delete older files from these directories: "
  echo " - $DIR_APP: files where the last modified time is more than $MTIME_APP days ago."
  echo " - $DIR_INI: files where the last modified time is more than $MTIME_INI days ago."
}

current_timestamp() {
  date --iso-8601=seconds
}

elapsed_time() {
  date --utc -d @$(expr "$(date --utc +%s)" - "$start_timestamp") +'%H:%M:%S'
}

print_debug() {
  if [[ $VERBOSE -ne 0 ]] ; then
    echo "# $(current_timestamp) - DEBUG: $1"
  fi
}

print_info() {
  echo "# $(current_timestamp) - INFO: $1"
}

print_error() {
  echo "# $(current_timestamp) - ERROR: $1"
}

delete_old_files() {
  ## The first argument is the target_dir
  target_dir=$1
  print_debug "target_dir=$target_dir"
  ## Second argument is the MTIME
  mtime_current=$2
  print_debug "mtime_current=$mtime_current"
  # Actual delete or Dry-Run:
  print_info "Deleting files from $target_dir ..."
  if [[ $DRY_RUN -ne 0 ]] ; then
    local cmd_text="find $target_dir -maxdepth 1 -type f -mtime +${mtime_current} -print"
    print_debug "cmd_text=$cmd_text"
    # Dry-run: fake-delete:
    find "$target_dir" -maxdepth 1 -type f -mtime "+${mtime_current}" -print
    exit_code=$?
    echo
    if [ $exit_code -ne 0 ]; then
      print_error "The find command returned with exit code: $exit_code"
      print_error "End. Total elapsed time: $(elapsed_time)"
      exit $exit_code
    fi
  else
    local cmd_text="find $target_dir -maxdepth 1 -type f -mtime +${mtime_current} -print0 | xargs -0 -r rm -f"
    print_debug "cmd_text=$cmd_text"
    # Actual delete:
    find "$target_dir" -maxdepth 1 -type f -mtime "+${mtime_current}" -print0 | xargs -0 -r rm -f
    exit_code=$?
    echo
    if [ $exit_code -ne 0 ]; then
      print_error "The find command returned with exit code: $exit_code."
      print_error "End. Total elapsed time: $(elapsed_time)"
      exit $exit_code
    fi
  fi
}

## Start
print_info "Start."

if [[ "$1" == "-h" ]] ; then
  usage
  exit 0
fi

print_debug "VERBOSE=$VERBOSE"
print_debug "DRY_RUN=$DRY_RUN"

if [[ $DRY_RUN -ne 0 ]] ; then
    # Dry-run: fake-delete:
    print_info "DRY_RUN is On"
fi

if [[ $VERBOSE -ne 0 ]] ; then
    # Verbose:
    print_debug "VERBOSE is On"
fi

print_info "The df report for $DIR_APP before:"
df -h $DIR_APP

## Real delete from $DIR_APP
delete_old_files $DIR_APP $MTIME_APP

print_info "The df report for $DIR_APP after delete:"
df -h $DIR_APP

print_info "The df report for $DIR_INI before:"
df -h $DIR_INI

## Real delete from $DIR_INI
delete_old_files $DIR_INI $MTIME_INI

print_info "The df report for $DIR_INI after delete:"
df -h $DIR_INI

print_info "End. Total elapsed time: $(elapsed_time)"
