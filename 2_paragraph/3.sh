#!/bin/bash

if [ $# -eq 0 ]; then
	echo -e "\033[31mError: No files provided.\033[0m"
	exit 1
fi

# Массив для хранения ID процессов
pids=()
files=()

for file in "$@"; do

	if [ -f "$file" ]; then

		if [[ "$file" =~ \.(jpg|jpeg)$ ]]; then
			convert "$file" "${file%.*}-converted.png" &
			pids+=($!)
			files+=("$file")

		else
			echo -e "\033[31mError: $file is not a valid image file.\033[0m"
		fi

	else
		echo -e "\033[31mError: File $file not found.\033[0m"
	fi
done

for i in "${!pids[@]}"; do
	wait ${pids[$i]}
	if [ $? -eq 0 ]; then
		echo -e "\033[32mConversion completed for file: ${files[$i]}.\033[0m"
	else
		echo -e "\033[31mError occurred during conversion for file: ${files[$i]}.\033[0m"
	fi
done
