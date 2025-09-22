#!/bin/bash

# ================================
# Log File Analyzer Script
# ================================

# Check if log file is given
if [ $# -ne 1 ]; then
  echo "Usage: $0 /path/to/logfile"
  exit 1
fi

LOGFILE="$1"

# Validate file exists
if [ ! -f "$LOGFILE" ]; then
  echo "Error: File '$LOGFILE' not found!"
  exit 1
fi

# Metadata
DATE_NOW=$(date +"%a %b %d %H:%M:%S %Z %Y")
FILE_SIZE_BYTES=$(stat -c%s "$LOGFILE")
FILE_SIZE_HUMAN=$(du -h "$LOGFILE" | cut -f1)

# Count messages
ERROR_COUNT=$(grep -c "ERROR" "$LOGFILE")
WARNING_COUNT=$(grep -c "WARNING" "$LOGFILE")
INFO_COUNT=$(grep -c "INFO" "$LOGFILE")

# Top 5 error messages
TOP_ERRORS=$(grep "ERROR" "$LOGFILE" \
  | sed -E 's/^\[[^]]+\] ERROR //' \
  | sort \
  | uniq -c \
  | sort -nr \
  | head -5)

# First and last error
FIRST_ERROR=$(grep "ERROR" "$LOGFILE" | head -1)
LAST_ERROR=$(grep "ERROR" "$LOGFILE" | tail -1)

# Error frequency by hour (00-23)
ERROR_FREQ=$(grep "ERROR" "$LOGFILE" \
  | sed -E 's/^\[([0-9-]+) ([0-9]{2}):[0-9]{2}:[0-9]{2}\].*/\2/' \
  | sort \
  | uniq -c)

# Scale bars for frequency visualization
MAX_COUNT=$(echo "$ERROR_FREQ" | awk '{print $1}' | sort -nr | head -1)
BAR_SCALE=50   # Max bar length

draw_bar() {
  COUNT=$1
  HOUR=$2
  BAR_LEN=$(( COUNT * BAR_SCALE / MAX_COUNT ))
  BAR=$(printf "%-${BAR_LEN}s" "#" | tr ' ' '#')
  echo "$(printf "%02d" $HOUR): $BAR ($COUNT)"
}

FREQ_REPORT=""
while read -r COUNT HOUR; do
  FREQ_REPORT+=$(draw_bar "$COUNT" "$HOUR")$'\n'
done <<< "$ERROR_FREQ"

# Output report
REPORT="log_analysis_$(date +%Y%m%d_%H%M%S).txt"

{
  echo "===== LOG FILE ANALYSIS REPORT ====="
  echo "File: $LOGFILE"
  echo "Analyzed on: $DATE_NOW"
  echo "Size: $FILE_SIZE_HUMAN ($FILE_SIZE_BYTES bytes)"
  echo
  echo "MESSAGE COUNTS:"
  echo "ERROR: $ERROR_COUNT messages"
  echo "WARNING: $WARNING_COUNT messages"
  echo "INFO: $INFO_COUNT messages"
  echo
  echo "TOP 5 ERROR MESSAGES:"
  echo "$TOP_ERRORS" | awk '{count=$1; $1=""; msg=substr($0,2); printf " %4d - %s\n", count, msg}'
  echo
  echo "ERROR TIMELINE:"
  echo "First error: $FIRST_ERROR"
  echo "Last error:  $LAST_ERROR"
  echo
  echo "Error frequency by hour:"
  echo "$FREQ_REPORT"
  echo
  echo "Report saved to: $REPORT"
} | tee "$REPORT"
