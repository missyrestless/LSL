#!/bin/bash
#
# view_chat - view the Second Life Firestorm viewer log history of chat or teleports
#
# Written May 3, 2026 by Missy Restless <missyrestless@gmail.com>
# Requires Mac or Linux, Windows may work with slight modification but is untested
#
## User defined variables
#
# Set to the default avatar folder you wish to use, dot replaced by underscore in Avatar name
DEF_AVI="missy_restless"
# Set one or both of these, Mac and/or Linux, to the default chat log you wish to view
MAC_DEF_CHAT="SierraAngelic"
LIN_DEF_CHAT="Doc Rae"
## END User defined variables

# Edit below this line only if you know what you are doing
USER=$(id -u -n)
MAC_DIR="/Users/${USER}/Library/Application Support/Firestorm"
LIN_DIR="/home/${USER}/.firestorm_x64"

usage() {
  printf "\nUsage: view_chat [-a my_avatar] [-c their_avatar] [-eflt] [-s search] [-h]"
  printf "\n\tDisplay chat or teleport history"
  printf "\nWhere:"
  printf "\n\t-a my_avatar specifies your avatar name [default: ${DEF_AVI}]"
  printf "\n\t-c their_avatar specifies avatar name of the person you chatted with [default: ${DEF_CHAT}]"
  printf "\n\t-e indicates edit mode"
  printf "\n\t-f indicates find chat files matching search term"
  printf "\n\t-i indicates ignore case when using search term"
  printf "\n\t-l indicates list files containing search term"
  printf "\n\t-s search specifies a search term"
  printf "\n\t-t indicates display teleport history"
  printf "\n\t-h displays this usage message and exits\n\n"
  exit 1
}

AVI= AVI_CHAT= CHAT= EDIT_MODE= FIND_CHAT= TP_HIST= GREP_OPTS= SEARCH= SHOW_USAGE=
while getopts ":a:c:efils:thu" flag; do
  case $flag in
    a)
      AVI="$OPTARG"
      ;;
    c)
      CHAT="$OPTARG"
      AVI_CHAT=1
      ;;
    e)
      EDIT_MODE=1
      ;;
    f)
      FIND_CHAT=1
      ;;
    i)
      GREP_OPTS="${GREP_OPTS} -i"
      ;;
    l)
      GREP_OPTS="${GREP_OPTS} -l"
      ;;
    s)
      SEARCH="$OPTARG"
      ;;
    t)
      TP_HIST=1
      ;;
    u|h)
      SHOW_USAGE=1
      ;;
    \?)
      echo "Invalid option: $flag"
      SHOW_USAGE=1
      ;;
  esac
done
shift $(( OPTIND - 1 ))

[ "${AVI}" ] || AVI="${DEF_AVI}"

platform=$(uname -o)
if [ "${platform}" == "Darwin" ]; then
  FDIR="${MAC_DIR}"
  DEF_CHAT="${MAC_DEF_CHAT}"
  [ "${CHAT}" ] || CHAT="${MAC_DEF_CHAT}"
else
  FDIR="${LIN_DIR}"
  DEF_CHAT="${LIN_DEF_CHAT}"
  [ "${CHAT}" ] || CHAT="${LIN_DEF_CHAT}"
fi

[ -d "${FDIR}/${AVI}" ] || {
  AVI=$(echo "${AVI}" | sed -e "s/\./_/g")
  [ -d "${FDIR}/${AVI}" ] || {
    echo "ERROR: cannot locate Avatar log folder ${FDIR}/${AVI}"
    SHOW_USAGE=1
  }
}

if [ "${TP_HIST}" ]; then
  CHAT="teleport_history.txt"
else
  [ -f "${FDIR}/${AVI}/${CHAT}" ] || CHAT="${CHAT}.txt"
fi

[ "${SHOW_USAGE}" ] && usage

# These Firestorm log files can have funny names with hyphens and spaces
# This can confuse some Linux/Unix utilities, interpreting them as command line options
# We use the '--' command line option to indicate the end of options to avoid this

if [ "${SEARCH}" ]; then
  cd "${FDIR}/${AVI}"
  if [ "${FIND_CHAT}" ]; then
    /bin/ls -1 *.txt | while read txt
    do
      echo "${txt}" | grep -i "${SEARCH}" >/dev/null && echo "${txt}"
    done
  else
    if [ "${TP_HIST}" ]; then
      grep ${GREP_OPTS} "${SEARCH}" "${CHAT}"*
    else
      if [ "${AVI_CHAT}" ]; then
        grep ${GREP_OPTS} "${SEARCH}" -- "${CHAT}"*
      else
        grep ${GREP_OPTS} "${SEARCH}" -- *.txt
      fi
    fi
  fi
else
  [ -f "${FDIR}/${AVI}/${CHAT}" ] || {
    echo "ERROR: cannot locate Avatar chat log ${FDIR}/${AVI}/${CHAT}"
    usage
  }
  if [ "${EDIT_MODE}" ]; then
    if [ "${EDITOR}" ]; then
      ${EDITOR} "${FDIR}/${AVI}/${CHAT}"
    else
      have_vim=$(type -p vim)
      if [ "${have_vim}" ]; then
        vim -- "${FDIR}/${AVI}/${CHAT}"
      else
        vi -- "${FDIR}/${AVI}/${CHAT}"
      fi
    fi
  else
    cat -- "${FDIR}/${AVI}/${CHAT}"
  fi
fi
