# Day 13 – Linux Volume Management (LVM)**

--> Switch to Root user --> sudi su - 

-->If there is no spare disk the by using below command lets create it,

1. dd if=/dev/zero of=/tmp/disk1.img bs=1M count=1024

2. losetup -fP /tmp/disk1.img

3. losetup -a   # Note the device name (e.g., /dev/loop0)

**Task 1: Check Current Storage**

Run commands: lsblk, pvs, vgs, lvs, df -h

<img width="952" height="912" alt="lvm-1" src="https://github.com/user-attachments/assets/e8f7b324-b385-4e54-9d13-f153665d0688" />

**Task 2: Create Physical Volume**

--> pvcreate /dev/sdb   # or your loop device

--> pvs

**Task 3: Create Volume Group**

--> vgcreate devops-vg /dev/sdb

--> vgs

<img width="875" height="957" alt="lvm-2" src="https://github.com/user-attachments/assets/ed3c71ee-9c3f-41d1-ac1b-d4258083d114" />

**Task 4: Create Logical Volume**

lvcreate -L 500M -n app-data devops-vg

lvs

**Task 5: Format and Mount**

mkfs.ext4 /dev/devops-vg/app-data

mkdir -p /mnt/app-data

mount /dev/devops-vg/app-data /mnt/app-data

df -h /mnt/app-data

<img width="865" height="851" alt="lvm-3" src="https://github.com/user-attachments/assets/cfb38970-c9e8-43e0-b772-8f2c609dfb67" />

**Task 6: Extend the Volume**

lvextend -L +200M /dev/devops-vg/app-data

resize2fs /dev/devops-vg/app-data

df -h /mnt/app-data

<img width="1135" height="947" alt="lvm-4" src="https://github.com/user-attachments/assets/cfdb3ae0-f6b9-4ba8-abaf-c3cbd090b920" />

**Documentations:**

**Commands Used:**

dd if=/dev/zero of=/tmp/disk1.img bs=1M count=1024

losetup -fP /tmp/disk1.img

losetup -a

lsblk

pvs

lvm

lsblk

df -h

pvcreate /dev/loop4

pvs

vgcreate devops-vg /dev/loop4

vgs

lvcreate -L 500M -n app-data devops-vg

lvs

mkfs.ext4 /dev/devops-vg/app-data

mkdir -p /mnt/app-data

mount /dev/devops-vg/app-data /mnt/app-data

df -h /mnt/app-data

lsblk

umount /mnt/app-data

lsblk

mount /dev/devops-vg/app-data /mnt/app-data

lsblk

lvextend -L +200M /dev/devops-vg/app-data

resize2fs /dev/devops-vg/app-data

df -h /mnt/app-data

**Full Cleanup in One Flow**

# 1. Unmount--> umount /mnt/app-data

# 2. Remove LV--> lvremove -f /dev/devops-vg/app-data

# 3. Remove VG--> vgremove devops-vg

# 4. Remove PVs--> pvremove /dev/loop4 /dev/loop5 /dev/loop7

# 5. Detach loop devices--> sudo losetup -D

# 6. Delete image files--> rm /tmp/disk*.img

# 7. Final verification--> pvs && vgs && lvs && lsblk

**What you learned (3 points)**

How to create virtual disk

How to create physical volumes, filesystems, volume groups, logical volumes, mount volumes

How to extend/resize volumes
