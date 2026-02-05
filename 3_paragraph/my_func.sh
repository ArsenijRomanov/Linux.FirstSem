#!/bin/bash

my_func() {
	if [ $# -lt 2 ]; then
		echo "Usage: my_func <output_file> <command> [args...]"
		return 1
	fi

	OUTPUT_FILE="$1"
	shift # Убираем первый аргумент, чтобы остались только команда и её аргументы

	"$@" >"$OUTPUT_FILE" 2>&1
}

my_func ./my-output ls -l
