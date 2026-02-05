#!/bin/bash

LATITUDE=""
LONGITUDE=""

while getopts "x:y:" option; do
	case "$option" in
	x) LONGITUDE="$OPTARG" ;;
	y) LATITUDE="$OPTARG" ;;
	*)
		echo "Usage: $0 -x <longitude> -y <latitude>"
		exit 1
		;;
	esac
done

if [ -z "$LATITUDE" ] || [ -z "$LONGITUDE" ]; then
	echo "Usage: $0 -x <longitude> -y <latitude>"
	exit 1
fi

echo "Getting weather for coordinates: Latitude=$LATITUDE, Longitude=$LONGITUDE"
curl "wttr.in/$LATITUDE,$LONGITUDE"
