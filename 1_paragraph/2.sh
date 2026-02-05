#!/bin/sh

awk '{printf("%.1f°C\n",$1/1000)}' /sys/class/thermal/thermal_zone0/temp
cat /sys/class/power_supply/BAT1/capacity
