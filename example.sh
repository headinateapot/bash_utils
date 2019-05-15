#!/usr/bin/env bash
# vim: tabstop=2 shiftwidth=2 expandtab

#
# Utility functions & template script 
#
# Args:
#   1 - 
#

set -u
set -o pipefail
#set -e
#set -x # favour (set -x; ./cmd.sh) OR bash -x cmd.sh

############################################################################
# Util functions
############################################################################
usage() {
  cat <<EOF
  Bash utility small functions
  Usage:
    ${CMD} <any arg>
EOF
}

info() {
  echo "# $@"
}

error() {
  echo "[ERROR] $@" >&2
}

error_exit() {
  error "$@"
  exit 1
}

sed_inline()
{
  local sed_pattern=$1
  local file=$2
  local tmp_file="$2.tmp"
  local _ret_

  sed "${sed_pattern}" "${file}" > "${tmp_file}"
  _ret_=$?
  if [[ ${_ret_} -eq 0 ]]; then
    mv "${tmp_file}" "${file}"
  else
    error "failed to run: sed ${sed_pattern} ${file} > ${tmp_file}"
    return ${_ret_}
  fi
}

source_dir()
{
  local source_dir=${BASH_SOURCE%/*}
  
  [[ "${source_dir}" == "${BASH_SOURCE}" ]] && source_dir='./'
  echo $(cd -P "${source_dir}" && pwd)
}

home_dir()
{
  local home_dir=${HOME%/*}
  echo "${home_dir}"
}

validate_args() {
  if [[ $# -ne 1 ]]; then
    usage
    error_exit 'Missing argument' 
  fi
}

print_end_message() {
  local return_val=$1

  if [[ ${return_val} -eq 0 ]]; then
    info 'done'
  else
    error "failed to execute ${CMD}"
    exit ${return_val}
  fi
}

############################################################################
# Global constants & variables
############################################################################
# get where this script is located so it can be run
# from any locations; symink handled
declare -r SOURCE_DIR=$(source_dir)

declare -r CMD="${0##*/}"

declare -r TIMESTAMP=$(date +"%Y%m%dT%H%M%S")

declare -r HOME_DIR=$(home_dir)

############################################################################
# Functions
############################################################################
_test_inline_sed() {
  local file="${TIMESTAMP}.txt"
  cat << EOF > "${file}"
This is a test line.
This is another test line.
EOF
  sed_inline 's/test/just/g' "${file}"
  cat "${file}"
  rm "${file}"
}

############################################################################
# Main
############################################################################
main() {
  local _ret_
  
  validate_args $@
 
  # execute...
  _test_inline_sed
 
  _ret_=$?
  
  print_end_message ${_ret_}
}

main $@
