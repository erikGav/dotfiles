#!/bin/bash
d=$(date +%u)
h=$(date +%H)

if { [ "$d" -ge 1 ] && [ "$d" -le 4 ]; } || [ "$d" -eq 7 ]; then
  if [ "$h" -ge 8 ] && [ "$h" -lt 19 ]; then
    exec slack
  fi
fi

