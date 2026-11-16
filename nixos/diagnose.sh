#!/usr/bin/env bash
# Find out what is slowing down the machine. Run it on the MacBook while it is
# slow, then paste the output into the conversation.
#   bash diagnose.sh > ~/diag.txt 2>&1
# Nothing here changes the system. Some lines need root (dmesg, journal).

section() { printf '\n===== %s =====\n' "$1"; }

section "Model"
cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null || echo "unknown"
uname -r

section "Disk type (ROTA=1 means spinning disk, the biggest suspect)"
lsblk -d -o NAME,MODEL,ROTA,SIZE,TRAN

section "Memory and swap"
free -h
swapon --show 2>/dev/null || echo "no swap active"
zramctl 2>/dev/null || echo "no zram device"

section "Load and the 10 biggest memory users"
uptime
ps -eo pid,comm,%cpu,%mem,rss --sort=-%mem | head -11

section "Disk and CPU wait over 5 seconds (wa high = waiting on disk)"
vmstat 1 5

section "Disk I/O per device (only if sysstat is installed)"
iostat -x 1 2 2>/dev/null | tail -n +4 || echo "iostat not available"

section "CPU speed, governor, and throttling count"
grep -m2 'model name\|cpu MHz' /proc/cpuinfo
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null
grep . /sys/devices/system/cpu/cpu*/thermal_throttle/core_throttle_count 2>/dev/null \
  || echo "no throttle counters"

section "Temperatures"
for z in /sys/class/thermal/thermal_zone*/temp; do
  [ -r "$z" ] && echo "$z: $(( $(cat "$z") / 1000 )) C"
done
sensors 2>/dev/null || echo "lm_sensors not available (run: nix-shell -p lm_sensors)"

section "Graphics and network hardware (and the driver in use)"
lspci -k 2>/dev/null | grep -EA3 'VGA|3D|Network' || echo "lspci not available (run: nix-shell -p pciutils)"

section "Compositor running?"
pgrep -a picom || echo "picom not running"

section "Recent kernel errors (disk, GPU, Wi-Fi, memory)"
dmesg --level=err,warn 2>/dev/null | tail -n 25 || echo "dmesg needs root"

section "Recent journal errors this boot"
journalctl -p err -b --no-pager 2>/dev/null | tail -n 25 || echo "journalctl needs root"
