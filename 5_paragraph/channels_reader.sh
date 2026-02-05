#!/bin/bash

if [ ! -p my-pipe ]; then
	echo "my-pipe does not exist"
	exit 1
fi

while true; do
	if read message <my-pipe; then
		echo "$(date) - $message"
	fi
done
