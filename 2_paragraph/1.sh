#!/bin/bash

if [ $# -eq 0 ]; then
	echo -e "\033[31mError: No files provided.\033[0m"
	exit 1
fi

for file in "$@"; do

	if [ -f "$file" ]; then
		convert "$file" "${file%.*}-converted.png"
		echo -e "\033[32mFile $file converted to ${file%.*}-converted.png\033[0m"

	else
		echo -e "\033[31mError: File $file not found.\033[0m"

	fi
done

# wget -O image1.jpg https://example.com/image1.jpg
