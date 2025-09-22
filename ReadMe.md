# 🖥️ Bash Scripting Assignments

This repository contains Bash scripting assignments focused on **system administration, automation, and monitoring**.

---

## 📌 Assignment 2:
# 🔍 Log Analyzer (Bash Script)

The **Log Analyzer** is a shell script that analyzes application/system log files and generates a detailed report.  
It helps developers and system admins quickly identify errors, warnings, and trends in logs.  

---

## ✨ Features
- 📂 Analyze any given log file  
- 📊 Count number of **ERROR**, **WARNING**, and **INFO** messages  
- 🏆 Show **Top 5 most frequent error messages**  
- 🕒 Display **first and last error with timestamps**  
- ⏰ Visualize **error frequency by hour** using ASCII bar charts  
- 💾 Automatically saves the report to a timestamped text file  

---

## ⚙️ Requirements
- Linux (Ubuntu recommended)  
- Basic shell utilities: `grep`, `sed`, `awk`, `sort`, `uniq`, `stat`, `du`  

---

## 📂 Project Structure
```

📁 log-analyzer
┣ 📜 log\_analyzer.sh   # Main Bash script
┣ 📜 sample.log        # Example log file for testing
┗ 📜 README.md         # Documentation

````

---

## 🚀 Usage

1. Make the script executable:
   ```bash
   chmod +x log_analyzer.sh
````

2. Run the script with a log file:

   ```bash
   ./log_analyzer.sh /var/log/application.log
   ```

3. The analysis will be printed to the terminal and also saved in a report file:

   ```
   log_analysis_YYYYMMDD_HHMMSS.txt
   ```

---

## 🖥️ Example Output

```
===== LOG FILE ANALYSIS REPORT =====
File: /var/log/application.log
Analyzed on: Fri Jul 12 14:32:15 EDT 2025
Size: 15.4MB (16,128,547 bytes)

MESSAGE COUNTS:
ERROR: 328 messages
WARNING: 1,253 messages
INFO: 8,792 messages

TOP 5 ERROR MESSAGES:
  182 - Database connection failed: timeout
   56 - Invalid authentication token provided
   43 - Failed to write to disk: Permission denied
   29 - API rate limit exceeded
   18 - Uncaught exception: Null pointer reference

ERROR TIMELINE:
First error: [2025-07-10 02:14:32] Database connection failed: timeout
Last error:  [2025-07-12 14:03:27] Failed to write to disk: Permission denied

Error frequency by hour:
00: ##### (72)
04: ## (23)
08: ############ (120)
12: ###### (63)
16: ### (34)
20: #### (16)

Report saved to: log_analysis_20250712_143215.txt
```

---

## System Health Monitor Dashboard

### 📖 Overview

The **System Health Monitor Dashboard** is an interactive Bash script that provides a **real-time terminal-based dashboard** for monitoring system metrics such as CPU, memory, disk, and network usage.

It is designed to help administrators quickly visualize system health with color-coded bars, detect anomalies, and take corrective action before critical failures occur.

---

### ✨ Features

* **Live Dashboard** – refreshes automatically every `3 seconds` (configurable).
* **System Information**

  * Hostname, uptime, current date & time.
* **CPU Monitoring**

  * Usage percentage with **ASCII/ANSI visual bar**.
  * Top 3 CPU-consuming processes.
* **Memory Monitoring**

  * Used/total memory with percentage and bar graph.
  * Top 3 memory-consuming processes.
* **Disk Usage**

  * Auto-detect partitions (`/`, `/var/log`, `/home`, etc.).
  * Color-coded thresholds:

    * ✅ OK (<70%)
    * ⚠️ Warning (70–85%)
    * 🔴 Critical (>85%)
* **Network Monitoring**

  * Auto-detects active network interface.
  * Displays **incoming/outgoing MB/s** rates.
* **Load Average** – 1m, 5m, 15m system load averages.
* **Alert Logging**

  * Anomalies (CPU > 80%, Memory > 75%, Disk > 85%) are logged in `system_alerts.log`.
* **Keyboard Shortcuts**

  * `[R]` → Change refresh rate
  * `[F]` → Filter by section (CPU, MEMORY, DISK, NETWORK, LOAD, ALL)
  * `[Q]` → Quit dashboard

---

### 📷 Sample Dashboard Output

```
╔════════════ SYSTEM HEALTH MONITOR v1.0 ════════════╗  [R]efresh: 3s
║ Hostname: webserver-prod1          Date: 2025-07-12 ║  [F]ilter: ALL
║ Uptime: 43 days, 7 hours, 13 minutes               ║  [Q]uit
╚═══════════════════════════════════════════════════════════════════════╝

CPU USAGE: 67% ████████████████████████████░░░░░░░░░░░░░░ [WARNING]
  Process: mongod (22%)
  Process: nginx (18%)
  Process: node (15%)

MEMORY: 5.8GB/8GB (73%) ████████████████████████░░░░░░░░░░ [WARNING]
  Process: chrome (15%)
  Process: java (12%)
  Process: redis (10%)

DISK USAGE:
  /        : 76% ████████████████████████████░░░░ [WARNING]
  /var/log : 42% ███████████░░░░░░░░░░░░░░░░░░░░ [OK]
  /home    : 28% █████░░░░░░░░░░░░░░░░░░░░░░░░░ [OK]

NETWORK (eth0):
  In : 18.2 MB/s ███████░░░░░░░░░░░░░░░░░░░░░░░ [OK]
  Out:  4.5 MB/s ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░ [OK]

LOAD AVERAGE: 2.34, 2.15, 1.98

RECENT ALERTS:
[14:25:12] CPU usage exceeded 80% (83%)
[14:02:37] Memory usage exceeded 75% (78%)
```

---

### 🚀 Usage

1. Clone this repository or copy the script.
2. Make the script executable:

   ```bash
   chmod +x system_monitor.sh
   ```
3. Run the dashboard:

   ```bash
   ./system_monitor.sh
   ```
4. Use shortcuts:

   * `R` → Set a new refresh rate.
   * `F` → Filter metrics (CPU, MEMORY, DISK, NETWORK, LOAD, ALL).
   * `Q` → Quit dashboard.

---

### 📝 Alert Log Example

The script logs anomalies in **system\_alerts.log**:

```
[2025-07-12 14:25:12] CPU usage exceeded 80% (83%)
[2025-07-12 14:02:37] Memory usage exceeded 75% (78%)
[2025-07-12 13:46:15] Disk usage on / exceeded 85% (86%)
```