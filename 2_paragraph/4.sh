#!/bin/bash

if [ $# -eq 0 ]; then
	echo -e "\033[31mError: No directory provided.\033[0m"
	exit 1
fi

if [ ! -d "$1" ]; then
	echo -e "\033[31mError: $1 is not a valid directory.\033[0m"
	exit 1
fi

find "$1" -type f -iname "*.jpg" | while read file; do
	convert "$file" "${file%.*}.png"
	echo -e "\033[32mConverted $file to ${file%.*}-converted.png\033[0m"
done
