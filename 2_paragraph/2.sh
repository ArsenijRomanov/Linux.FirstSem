#!/bin/bash

find /sys -type f -name "temp*input" 2>/dev/null | while read sensor_file; do

	echo "Sensor: $sensor_file"

	awk '{printf("%.1f°C\n",$1/1000)}' "$sensor_file"
	echo ""
done
