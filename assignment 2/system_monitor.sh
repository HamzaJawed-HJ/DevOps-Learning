#!/bin/bash

# ================================
# System Health Monitor Dashboard
# ================================

REFRESH=3
ALERT_LOG="system_alerts.log"
FILTER="ALL"

# Colors
RED="\e[31m"
YELLOW="\e[33m"
GREEN="\e[32m"
CYAN="\e[36m"
RESET="\e[0m"

# Draw bar function
draw_bar() {
  local percent=$1
  local length=40
  local filled=$(( percent * length / 100 ))
  local empty=$(( length - filled ))
  printf "%s%s" "$(printf '█%.0s' $(seq 1 $filled))" "$(printf '░%.0s' $(seq 1 $empty))"
}

# Get top 3 processes by CPU
top_processes() {
  ps -eo comm,%cpu --sort=-%cpu | head -4 | tail -3 | awk '{printf "  %s (%s%%)\n", $1, $2}'
}

# Get top 3 processes by Memory
top_mem_processes() {
  ps -eo comm,%mem --sort=-%mem | head -4 | tail -3 | awk '{printf "  %s (%s%%)\n", $1, $2}'
}

# Detect main network interface
NET_IFACE=$(ip route get 8.8.8.8 | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' | head -1)

# Track previous RX/TX for speed calculation
prev_rx=0
prev_tx=0

# Main loop
while true; do
  clear
  DATE_NOW=$(date +"%Y-%m-%d %H:%M:%S")
  HOSTNAME=$(hostname)
  UPTIME=$(uptime -p | sed 's/^up //')

  echo -e "╔════════════ ${CYAN}SYSTEM HEALTH MONITOR v1.0${RESET} ════════════╗  [R]efresh: ${REFRESH}s"
  echo -e "║ Hostname: $HOSTNAME\tDate: $DATE_NOW ║  [F]ilter: $FILTER"
  echo -e "║ Uptime: $UPTIME\t\t\t║  [Q]uit"
  echo -e "╚═══════════════════════════════════════════════════════════════════════╝"
  echo

  # CPU
  if [[ $FILTER == "ALL" || $FILTER == "CPU" ]]; then
    CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d. -f1)
    CPU_USE=$((100 - CPU_IDLE))

    if [ $CPU_USE -lt 60 ]; then COLOR=$GREEN; STATUS="[OK]"
    elif [ $CPU_USE -lt 80 ]; then COLOR=$YELLOW; STATUS="[WARNING]"
    else COLOR=$RED; STATUS="[CRITICAL]"
      echo "[$DATE_NOW] CPU usage exceeded 80% ($CPU_USE%)" >> $ALERT_LOG
    fi

    echo -e "CPU USAGE: $CPU_USE% ${COLOR}$(draw_bar $CPU_USE)${RESET} $STATUS"
    top_processes
    echo
  fi

  # Memory
  if [[ $FILTER == "ALL" || $FILTER == "MEMORY" ]]; then
    read total used free shared buff cache available <<< $(free -m | awk 'NR==2{print $2, $3, $4, $5, $6, $7, $7}')
    PERCENT=$(( used * 100 / total ))

    if [ $PERCENT -lt 60 ]; then COLOR=$GREEN; STATUS="[OK]"
    elif [ $PERCENT -lt 75 ]; then COLOR=$YELLOW; STATUS="[WARNING]"
    else COLOR=$RED; STATUS="[CRITICAL]"
      echo "[$DATE_NOW] Memory usage exceeded 75% ($PERCENT%)" >> $ALERT_LOG
    fi

    echo -e "MEMORY: ${used}MB/${total}MB (${PERCENT}%) ${COLOR}$(draw_bar $PERCENT)${RESET} $STATUS"
    top_mem_processes
    echo
  fi

  # Disk
  if [[ $FILTER == "ALL" || $FILTER == "DISK" ]]; then
    echo "DISK USAGE:"
    df -h --output=target,pcent | tail -n +2 | while read line; do
      mount=$(echo $line | awk '{print $1}')
      usage=$(echo $line | awk '{print $2}' | tr -d '%')
      if [ $usage -lt 70 ]; then COLOR=$GREEN; STATUS="[OK]"
      elif [ $usage -lt 85 ]; then COLOR=$YELLOW; STATUS="[WARNING]"
      else COLOR=$RED; STATUS="[CRITICAL]"
        echo "[$DATE_NOW] Disk usage on $mount exceeded 85% ($usage%)" >> $ALERT_LOG
      fi
      echo -e "  $mount : ${usage}% ${COLOR}$(draw_bar $usage)${RESET} $STATUS"
    done
    echo
  fi

  # Network
  if [[ $FILTER == "ALL" || $FILTER == "NETWORK" ]]; then
    rx=$(cat /sys/class/net/$NET_IFACE/statistics/rx_bytes)
    tx=$(cat /sys/class/net/$NET_IFACE/statistics/tx_bytes)

    if [ $prev_rx -ne 0 ]; then
      rx_rate=$(( (rx - prev_rx) / (REFRESH * 1024 * 1024) ))
      tx_rate=$(( (tx - prev_tx) / (REFRESH * 1024 * 1024) ))
      echo -e "NETWORK ($NET_IFACE):"
      echo -e "  In : ${rx_rate} MB/s $(draw_bar $((rx_rate*5)))"
      echo -e "  Out: ${tx_rate} MB/s $(draw_bar $((tx_rate*5)))"
    fi
    prev_rx=$rx
    prev_tx=$tx
    echo
  fi

  # Load average
  if [[ $FILTER == "ALL" || $FILTER == "LOAD" ]]; then
    LOAD=$(uptime | awk -F'load average:' '{ print $2 }')
    echo "LOAD AVERAGE:$LOAD"
    echo
  fi

  # Recent alerts
  echo "RECENT ALERTS:"
  tail -5 $ALERT_LOG 2>/dev/null
  echo

  # Wait for keypress or refresh
  read -t $REFRESH -n 1 key
  if [[ $key == "q" || $key == "Q" ]]; then
    clear
    echo "Exiting System Monitor..."
    exit 0
  elif [[ $key == "r" || $key == "R" ]]; then
    echo -n "Enter new refresh rate (seconds): "
    read new_rate
    REFRESH=$new_rate
  elif [[ $key == "f" || $key == "F" ]]; then
    echo -n "Enter filter (ALL/CPU/MEMORY/DISK/NETWORK/LOAD): "
    read FILTER
  fi
done
