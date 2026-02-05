#!/bin/bash

if [ $# -ne 1 ] || [ ! -f "$1" ]; then
	echo "usage: open [file]"
	echo "Ensure that only one existing file is transferred"
	exit 1
fi

FILE="$1"

MIME_TYPE=$(file --mime-type -b "$FILE")

case "$MIME_TYPE" in
image/*)
	nohup gimp "$FILE" &>/dev/null &
	;;
application/msword | application/vnd.ms-excel | application/vnd.ms-powerpoint | application/vnd.openxmlformats-officedocument.wordprocessingml.document)
	nohup libreoffice "$FILE" &>/dev/null &
	;;
video/* | audio/*)
	nohup mpv "$FILE" &>/dev/null &
	;;
*)
	echo "Unknown MIME type: $MIME_TYPE. No suitable program to open the file"
	exit 1
	;;
esac

exit 0
