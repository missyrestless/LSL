#!/bin/bash

FSFE="/opt/Firestorm/firestorm"
FMAC="/Applications/Firestorm-Releasex64.app/Contents/MacOS/Firestorm"

usage() {
  printf "\nUsage: firestorm [-l logfile] [-n] [-v] [-x /path/to/firestorm] [-u]"
  printf "\nWhere:"
  printf "\n\t-l logfile specifies the output log location"
  printf "\n\t-n indicates tell me what you would do but do nothing"
  printf "\n\t-v indicates verbose mode"
  printf "\n\t-x /path/to/firestorm specifies the path to the firestorm script"
  printf "\n\t-u displays this usage message and exits\n"
  printf "\nThis Firestorm front-end executes the Firestorm script:"
  printf "\n\t${FSFE}\n\n"
  exit 1
}

platform=$(uname -s)
[ "${platform}" == "Darwin" ] && FSFE="${FMAC}"

FLOG=
TELL=
VERB=
while getopts ":l:nuvx:" flag; do
  case $flag in
    l)
      FLOG="$OPTARG"
      ;;
    n)
      TELL=1
      ;;
    v)
      VERB=1
      ;;
    x)
      FSFE="$OPTARG"
      ;;
    u)
      usage
      ;;
    \?)
      echo "Invalid option: $flag"
      usage
      ;;
  esac
done
shift $(( OPTIND - 1 ))

if [ -x "${FSFE}" ]; then
  if [ "${VERB}" ]; then
    if [ "${FLOG}" ]; then
      if [ "${TELL}" ]; then
        echo "exec \"${FSFE}\" > ${FLOG} 2>&1 &"
      else
        exec "${FSFE}" > ${FLOG} 2>&1 &
      fi
      echo "Firestorm stdout and stderr is redirected to ${FLOG}"
    else
      if [ "${TELL}" ]; then
        echo "exec \"${FSFE}\""
      else
        exec "${FSFE}"
      fi
    fi
  else
    if [ "${FLOG}" ]; then
      if [ "${TELL}" ]; then
        echo "exec \"${FSFE}\" > ${FLOG} 2>&1 &"
      else
        exec "${FSFE}" > ${FLOG} 2>&1 &
      fi
      echo "Firestorm stdout and stderr is redirected to ${FLOG}"
    else
      if [ "${TELL}" ]; then
        echo "exec \"${FSFE}\" > /dev/null 2>&1 &"
      else
        exec "${FSFE}" > /dev/null 2>&1 &
      fi
    fi
  fi
else
  echo "ERROR: could not locate "${FSFE}" executable"
  exit 1
fi
