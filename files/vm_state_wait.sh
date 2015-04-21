#!/bin/bash
# ---------------------------------------------------------------------
# Shell script to wait until the the status of KVM VM changes
# ---------------------------------------------------------------------

DEFAULT_STATE="shut"
DEFAULT_TIMEOUT=60      # seconds

KVM_CMD="sudo virsh list --all"

function usage() {
  cat << EOF
usage: $0 [ -s <desired state> ] [ -t <timeout> ] vm-name
EOF
  exit $1
}

function run_kvm_cmd() {
  ${KVM_CMD} | awk "NR > 2 && \$2 ~ \"$1\" && NF >= 3 { print \$3 }"
}

function get_vm_state() {
  local vm_name="${1}"  
  local state="$(run_kvm_cmd ${vm_name})"

  case "${state}" in
    "running" | "shut" )  echo "${state}" ;;
    * )                   echo "unknown"  ;;
  esac
}

function is_vm_state() {
  local vm_name="${1}"  
  local vm_desired_state="${2}"

  test "$(get_vm_state ${vm_name})" == "${vm_desired_state}"
}

# main ----------------------------------------------------------------

STATE="${DEFAULT_STATE}"
TIMEOUT="${DEFAULT_TIMEOUT}"
HOST=""

while getopts "s:t:" opt; do
  case ${opt} in 
    s ) STATE="${OPTARG}"   ;;
    t ) TIMEOUT="${OPTARG}" ;;
    * ) usage 127 ;;
  esac
done

shift $((OPTIND-1))

HOST="$1"
[[ -z "${HOST}" ]] && usage 126 

waited_seconds=0
sleep_seconds=1

while (( waited_seconds < TIMEOUT ))
do
    # if state transition to desired state the wait is over
    if is_vm_state "${HOST}" "${STATE}"; then
      echo "yes"
      exit 0
    fi

    # echo "vm state = $(get_vm_state ${HOST}), desired state = ${STATE}"
    sleep ${sleep_seconds}
    (( waited_seconds = waited_seconds + sleep_seconds))
    (( sleep_seconds = sleep_seconds * 2 ))
done

# timeout expired, vm state did not transition to desired state
echo "no"
exit 0

# ---------------------------------------------------------------------
# eof
#