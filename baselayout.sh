#!/bin/sh

set -e
source ./filetree.env

mkdir -pv ${TARGET_SYSROOT}/{bin,boot,dev,etc,home,lib/{firmware,modules}}
mkdir -pv ${TARGET_SYSROOT}/{mnt,opt,proc,sbin,srv,sys}
mkdir -pv ${TARGET_SYSROOT}/var/{cache,lib,local,lock,log,opt,run,spool}
install -dv -m 0750 ${TARGET_SYSROOT}/root
install -dv -m 1777 ${TARGET_SYSROOT}/tmp
mkdir -pv ${TARGET_SYSROOT}/usr/{,local/}{bin,include,lib,sbin,share,src}

ln -svf ../proc/mounts ${TARGET_SYSROOT}/etc/mtab
cat > ${TARGET_SYSROOT}/etc/passwd << "EOF"
root::0:0:root:/root:/bin/ash
EOF

cat > ${TARGET_SYSROOT}/etc/group << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tty:x:4:
tape:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
EOF

touch ${TARGET_SYSROOT}/var/run/utmp ${TARGET_SYSROOT}/var/log/{btmp,lastlog,wtmp}
chmod -v 664 ${TARGET_SYSROOT}/var/run/utmp ${TARGET_SYSROOT}/var/log/lastlog

cat > ${TARGET_SYSROOT}/etc/fstab << "EOF"
# file-system        mount-point          type       options            dump  fsck
/dev/root            /                    auto       defaults              1  1
proc                 /proc                proc       defaults              0  0
devpts               /dev/pts             devpts     mode=0620,gid=5       0  0
tmpfs                /run                 tmpfs      mode=0755,nodev,nosuid,strictatime 0  0
tmpfs                /var/volatile        tmpfs      defaults              0  0
EOF
