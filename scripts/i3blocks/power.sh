#!/bin/bash

CPU_TDP=65        # i7-7700 TDP in watts
OTHER_POWER=40    # motherboard + RAM + SSD + fans

CPU_LOAD=$(top -bn2 | grep "Cpu(s)" | tail -n1 | \
           awk -F',' '{usage=100-$8; print usage}')

CPU_POWER=$(echo "$CPU_TDP * $CPU_LOAD / 100" | bc -l)

if command -v nvidia-smi &> /dev/null; then
    GPU_POWER=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits 2>/dev/null || echo 0)
else
    GPU_POWER=0
fi

TOTAL=$(echo "$CPU_POWER + $GPU_POWER + $OTHER_POWER" | bc -l)
TOTAL_FMT=$(printf "%.0f" "$TOTAL")

# full text
echo "${TOTAL_FMT}W"
# short text
echo "${TOTAL_FMT}W"
