#!/usr/bin/env python3
import os
import platform
import multiprocessing
import subprocess
import time
import sys
# Get architecture information:

architecture = platform.uname()
kernel_version = os.uname()
num_processors = multiprocessing.cpu_count()
# Get CPU & vCPU informations:
with open("/proc/cpuinfo", "r") as f:
	cpuinfo = f.read().split("\n")
vcpu_count = 0
for line in cpuinfo:
	if line.startswith("processor"):
		vcpu_count += 1
# Get Memory usage information:

memory = os.popen("free --mega").read().split("\n")
memory_line = memory[1]
fields = memory_line.split()
memory_total = fields[1]
memory_used = fields[2]
memory_percent = int(memory_used) / int(memory_total) * 100
memory_percent = round(memory_percent,2)
# Get Disk Usage information:

disk = os.popen("df -h --total").read()
splitted_disk = disk.split("\n")
for splited in splitted_disk:
	if (splited.startswith('total')):
		used_disk = splited.split()[2]
		avail_disk = splited.split()[3]
		avail_disk = avail_disk.replace(avail_disk[-1], "")
		used_disk = used_disk.replace(used_disk[-1],"")
		mega_disk = float(used_disk) * 1000
total_disk = round(int(float(used_disk)) / int(avail_disk) *100, 2)
# Get CPU Load information:
with open('/proc/stat','r') as f:
	stats = f.readline()
cpu_fields = stats.split()
user = cpu_fields[1]
nice = cpu_fields[2]
system = cpu_fields[3]
idle = cpu_fields[4]
iowait = cpu_fields[5]
irq = cpu_fields[6]
softirq = cpu_fields[7]
steal = cpu_fields[8]
guest = cpu_fields[9]
guest_nice = cpu_fields[10]
total_time = user + nice + system + idle + iowait + irq + softirq
cpu_load = 100 * (int(user) + int(nice) + int(system)) / int(total_time)

# Get Last boot information:
last_boot_splitted = os.popen("who -b").read().split()

# Get LVM activity information:
LVM = os.popen("lsblk -o +TYPE").read().split()
if "lvm" in LVM:
	LVM_info = "Yes"
else:
	LVM_info = "No"

# Get active connections information:
Connections  = os.popen("ss -t | wc -l").read().replace("\n","")

# Get number of users information:
users = os.popen("who | wc -l").read().replace("\n","")

# Get IP adress and Mac adress:
ip_adress = os.popen("hostname -I").read().replace("\n","")
mac_address = os.popen("ip link").read().split("\n")
for mac_line in mac_address:
	if "link/ether" in mac_line:
		mac_line_splitted = mac_line.split()
		mac = mac_line_splitted[1]
		break

# Get sudo number of commands information:
sudo_comm = os.popen("journalctl -eq /usr/bin/sudo | grep COMMAND | wc -l").read().replace("\n","")

#using wall command to display messages
os.system(f"echo '#Architecture {kernel_version[0]} {kernel_version[1]} {kernel_version[2]}  {kernel_version[4]} {architecture.system} \n#CPU physical: {num_processors}\n#vCPU: {vcpu_count}\n#Memory Usage: {memory_used} / {memory_total}MB ({memory_percent}%)\n#Disk Usage: {int(mega_disk)}/{avail_disk}Gb ({total_disk}%)\n#CPU load: {int(cpu_load)}\n#Last boot: {last_boot_splitted[2]} {last_boot_splitted[3]}\n#LVM use: {LVM_info}\n#Connections TCP: {Connections} ESTABLISHED\n#User log: {users}\n#Network: {ip_adress} ({mac})\n#Sudo: {sudo_comm} cmd' | wall")
