#!/bin/bash
apt-get update

groupadd sugroup #Create an empty group that will be specified for use of the su command.
echo "auth required pam_wheel.so use_uid group=sugroup" >> /etc/pam.d/su

#Ensure login and logout events are collected
apt-get install -y auditd #install auditd package
echo "-w /var/log/faillog -p wa -k logins" >> /etc/audit/rules.d/audit.rules
echo "-w /var/log/lastlog -p wa -k logins" >> /etc/audit/rules.d/audit.rules
echo "-w /var/log/sudo.log -p wa -k actions" >> /etc/audit/rules.d/audit.rules

#Ensure default user shell timeout is 600 seconds or less
echo "readonly TMOUT=900 ; export TMOUT" >> /etc/profile

#Ensure unsuccessful unauthorized file access attempts are collected
echo "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access" >> /etc/audit/rules.d/access.rules
echo "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access" >> /etc/audit/rules.d/access.rules
echo "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access" >> /etc/audit/rules.d/access.rules
echo "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access" >> /etc/audit/rules.d/access.rules

#Ensure events that modify user/group information are collected
echo "-w /etc/group -p wa -k identity" >> /etc/audit/rules.d/identity.rules
echo "-w /etc/passwd -p wa -k identity" >> /etc/audit/rules.d/identity.rules
echo "-w /etc/gshadow -p wa -k identity" >> /etc/audit/rules.d/identity.rules
echo "-w /etc/shadow -p wa -k identity" >> /etc/audit/rules.d/identity.rules
echo "-w /etc/security/opasswd -p wa -k identity" >> /etc/audit/rules.d/identity.rules

#Ensure journald is configured to send logs to rsyslog
sed -i 's/#ForwardToSyslog=yes/ForwardToSyslog=yes/g' /etc/systemd/journald.conf

#Ensure journald is configured to compress large log files
sed -i 's/#Compress=yes/Compress=yes/g' /etc/systemd/journald.conf

#Ensure journald is configured to write logfiles to persistent disk
sed -i 's/#Storage=auto/Storage=persistent/g' /etc/systemd/journald.conf
sed -i 's/#SystemMaxUse=/SystemMaxUse=100M/g' /etc/systemd/journald.conf
sed -i 's/#MaxFileSec=1month/MaxFileSec=7day/g' /etc/systemd/journald.conf

#Ensure session initiation information is collected
echo "-w /var/run/utmp -p wa -k session" >> /etc/audit/rules.d/logins.rules
echo "-w /var/log/wtmp -p wa -k logins" >> /etc/audit/rules.d/logins.rules
echo "-w /var/log/btmp -p wa -k logins" >> /etc/audit/rules.d/logins.rules

#Ensure successful file system mounts are collected
echo "-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" >> /etc/audit/rules.d/mounts.rules
echo "-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" >> /etc/audit/rules.d/mounts.rules

#Ensure file deletion events by users are collected
echo "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" >> /etc/audit/rules.d/delete.rules
echo "-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" >> /etc/audit/rules.d/delete.rules

#Ensure kernel module loading and unloading is collected
echo "-w /sbin/insmod -p x -k modules" >> /etc/audit/rules.d/modules.rules
echo "-w /sbin/rmmod -p x -k modules" >> /etc/audit/rules.d/modules.rules
echo "-w /sbin/modprobe -p x -k modules" >> /etc/audit/rules.d/modules.rules
echo "-a always,exit -F arch=b64 -S init_module -S delete_module -k modules" >> /etc/audit/rules.d/modules.rules

#Ensure sudo log file exists
echo "Defaults logfile="/var/log/sudo.log"" >> /etc/sudoers

#Ensure changes to system administration scope (sudoers) is collected
echo "-w /etc/sudoers -p wa -k scope" >> /etc/audit/rules.d/scope.rules
echo "-w /etc/sudoers.d/ -p wa -k scope" >> /etc/audit/rules.d/scope.rules

#Ensure events that modify the system's network environment are collected
echo "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/rules.d/system-locale.rules
echo "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/rules.d/system-locale.rules
echo "-w /etc/issue -p wa -k system-locale" >> /etc/audit/rules.d/system-locale.rules
echo "-w /etc/issue.net -p wa -k system-locale" >> /etc/audit/rules.d/system-locale.rules
echo "-w /etc/hosts -p wa -k system-locale" >> /etc/audit/rules.d/system-locale.rules
echo "-w /etc/sysconfig/network -p wa -k system-locale" >> /etc/audit/rules.d/system-locale.rules

#Ensure discretionary access control permission modification events are collected
echo ""-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod >> /etc/audit/rules.d/perm_mod.rules
echo ""-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod >> /etc/audit/rules.d/perm_mod.rules
echo ""-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod >> /etc/audit/rules.d/perm_mod.rules
echo ""-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod >> /etc/audit/rules.d/perm_mod.rules
echo ""-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod >> /etc/audit/rules.d/perm_mod.rules
echo ""-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod >> /etc/audit/rules.d/perm_mod.rules

#Ensure events that modify date and time information are collected
echo "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change" >> /etc/audit/rules.d/time-change.rules
echo "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change" >> /etc/audit/rules.d/time-change.rules
echo "-a always,exit -F arch=b64 -S clock_settime -k time-change" >> /etc/audit/rules.d/time-change.rules
echo "-a always,exit -F arch=b32 -S clock_settime -k time-change" >> /etc/audit/rules.d/time-change.rules
echo "-w /etc/localtime -p wa -k time-change" >> /etc/audit/rules.d/time-change.rules

#Ensure logrotate is configured
#Edit `/etc/logrotate.conf` and `/etc/logrotate.d/*` to ensure logs are rotated according to site policy.

#Ensure events that modify the system's Mandatory Access Controls are collected
echo ""-w /etc/selinux/ -p wa -k MAC-policy >> /etc/audit/rules.d/MAC-policy.rules
echo ""-w /usr/share/selinux/ -p wa -k MAC-policy >> /etc/audit/rules.d/MAC-policy.rules

#Ensure audit log storage size is configured
sed -i 's/max_log_file = 8/max_log_file = 10/' /etc/audit/auditd.conf
sed -i 's/max_log_file_action = ROTATE/max_log_file_action = keep_logs/' /etc/audit/auditd.conf
sed -i 's/space_left_action = SYSLOG/space_left_action = email/' /etc/audit/auditd.conf
sed -i 's/action_mail_acct = root/action_mail_acct = root/' /etc/audit/auditd.conf
sed -i 's/admin_space_left_action = SUSPEND/admin_space_left_action = halt/' /etc/audit/auditd.conf

# Ensure system Swap Memory is enough to 4 to 4.5 GB
#sudo swapoff -a
#swapoff -a
#dd if=/dev/zero of=/swapfile bs=1M count=4096
#chmod 600 /swapfile
#mkswap /swapfile
#echo " /swapfile swap swap defaults 0 0" >> /etc/fstab


#Ensure system Swappiness is set to 5
echo ""net.ipv4.ip_local_port_range = 20001 60999  >> /etc/sysctl.conf
echo ""net.ipv4.tcp_fin_timeout = 15 >> /etc/sysctl.conf
echo ""vm.swappiness=5 >> /etc/sysctl.conf
sysctl -p

#Ensure Ipv6 is disable
echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6=1" >> /etc/sysctl.conf
