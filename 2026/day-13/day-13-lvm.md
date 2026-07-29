# Day 13 – Linux Volume Management (LVM)

## Task
Learn LVM to manage storage flexibly – create, extend, and mount volumes.

**Watch First:** [Linux LVM Tutorial](https://youtu.be/Evnf2AAt7FQ?si=ncnfQYySYtK_2K3c)

---

## Expected Output
- A markdown file: `day-13-lvm.md`
- Screenshots of command outputs

---

## Before You Start

Switch to root user:
```bash
sudo -i
```
or
```bash
sudo su
```
No spare disk? Create a virtual one (watch the tutorial):
```bash
dd if=/dev/zero of=/tmp/disk1.img bs=1M count=1024
losetup -fP /tmp/disk1.img
losetup -a   # Note the device name (e.g., /dev/loop0)
```

---

## Challenge Tasks

### Task 1: Check Current Storage
Run: `lsblk`, `pvs`, `vgs`, `lvs`, `df -h`

**Steps to follow:**

-->This task is about understanding your Linux system's storage before making any changes. Run each command one by one and observe the output.

Step 1: Become the root user: sudo -i

-->verify your root: whoami

Step 2: Check Block Devices (lsblk): lsblk [Note: This shows all disks, partitions, loop devices, and mounted filesystems.]

<img width="792" height="547" alt="image" src="https://github.com/user-attachments/assets/1424754d-f858-4ed7-ade8-c13e17d17975" />

<img width="1230" height="212" alt="image" src="https://github.com/user-attachments/assets/d29bbdee-9236-454a-b424-9736fa0bcb42" />

- sdd is your main WSL disk (1 TB) and contains your root filesystem (/).
- sdc is the WSL swap disk.
- There is no extra disk (such as /dev/loop0) yet.

Step 3: Check Physical Volumes (pvs): pvs

Note: pvs is not availble bydefault we have to install it separately: sudo apt update && sudo apt install lvm2 -y

<img width="782" height="751" alt="image" src="https://github.com/user-attachments/assets/9ce34816-eddd-4408-919d-594474da5a81" />

<img width="1452" height="962" alt="image" src="https://github.com/user-attachments/assets/27b73193-277c-464b-b040-bc33dad56e41" />

<img width="1906" height="951" alt="image" src="https://github.com/user-attachments/assets/5cbeb633-73f6-422b-9f6b-cfea013ad74d" />

<img width="1731" height="27" alt="image" src="https://github.com/user-attachments/assets/f672d58c-a044-475e-a666-1faba18a6793" />

-->No Physical Volumes (PV) exist.

Step 4: Check Volume Groups (vgs): vgs 

<img width="802" height="321" alt="image" src="https://github.com/user-attachments/assets/eb367175-50dd-452f-8060-9919fe8a91be" />

<img width="1611" height="25" alt="image" src="https://github.com/user-attachments/assets/c40fa9a7-1be5-45ea-904b-e54459a27c55" />

-->No Volume Groups (VG) exist.

Step 5: Check Logical Volumes (lvs): lvs

<img width="792" height="272" alt="image" src="https://github.com/user-attachments/assets/8a1d02b7-0374-466d-8a4a-b011e138c07c" />

<img width="1662" height="22" alt="image" src="https://github.com/user-attachments/assets/addf9908-24f7-4f24-8e0f-cc77a59c5478" />

-->No Logical Volumes (LV) exist.

Step 6: Check Filesystem Usage (df -h): df -h

<img width="770" height="377" alt="image" src="https://github.com/user-attachments/assets/bc1280f5-e145-4693-86bc-d4c86ce2e1be" />

<img width="1791" height="442" alt="image" src="https://github.com/user-attachments/assets/fcf271e7-5b82-4014-86a8-ff0a488f39bb" />

-->Absolutely! Let's understand df -h line by line. This is one of the most important Linux commands for DevOps.

<img width="745" height="722" alt="image" src="https://github.com/user-attachments/assets/7089b97a-4f4d-4cca-bbf0-42fd3a401729" />

Let's go through your output:

<img width="707" height="662" alt="image" src="https://github.com/user-attachments/assets/36853c2b-c1f3-4604-bebc-7912a2490afb" />

<img width="712" height="371" alt="image" src="https://github.com/user-attachments/assets/a946d274-c4dc-49ad-838a-af7d918fd09b" />

<img width="651" height="651" alt="image" src="https://github.com/user-attachments/assets/9c3e858b-db25-4279-960c-23235108ad09" />

<img width="702" height="787" alt="image" src="https://github.com/user-attachments/assets/86e7d626-50cc-44b6-b61d-e16563856df3" />

<img width="705" height="442" alt="image" src="https://github.com/user-attachments/assets/95f49ea4-4703-460b-81f5-208595f685ad" />

<img width="710" height="797" alt="image" src="https://github.com/user-attachments/assets/e7d79de5-4f1a-44f3-a387-28205ddc2e28" />

<img width="662" height="391" alt="image" src="https://github.com/user-attachments/assets/ab7d6356-6fa6-4ea6-acb0-225c8ba8dd02" />

<img width="677" height="497" alt="image" src="https://github.com/user-attachments/assets/03337a65-6f63-44cf-b55b-97ed34bf569d" />

<img width="717" height="507" alt="image" src="https://github.com/user-attachments/assets/cf388ea2-ff73-4f19-9e8f-85b771900b3c" />

<img width="685" height="781" alt="image" src="https://github.com/user-attachments/assets/d90eff6b-220c-4c52-93ce-56a6d59ef09b" />

Visualising your storage:

<img width="675" height="507" alt="image" src="https://github.com/user-attachments/assets/d04ee58a-255b-4d38-9fb2-e8bafb826fc8" />

Q. Why don't pvs, vgs, and lvs show anything?

<img width="750" height="611" alt="image" src="https://github.com/user-attachments/assets/4b5f5387-405c-4624-b204-b2129d9d5aee" />

-->Since there are no Physical Volumes (PVs), Volume Groups (VGs), or Logical Volumes (LVs), the pvs, vgs, and lvs commands return no output.

If you created a virtual disk: 

<img width="762" height="517" alt="image" src="https://github.com/user-attachments/assets/a52ff6a3-87a9-4d1e-b6f7-8e2f7767c671" />

Overall Summary: Your system is using a normal filesystem, not LVM.

<img width="812" height="306" alt="image" src="https://github.com/user-attachments/assets/8f72140e-cda6-4eeb-bd7d-2903dfe440a3" />

### Task 2: Create Physical Volume
```bash
pvcreate /dev/sdb   # or your loop device
pvs
```

### Task 3: Create Volume Group
```bash
vgcreate devops-vg /dev/sdb
vgs
```

### Task 4: Create Logical Volume
```bash
lvcreate -L 500M -n app-data devops-vg
lvs
```

### Task 5: Format and Mount
```bash
mkfs.ext4 /dev/devops-vg/app-data
mkdir -p /mnt/app-data
mount /dev/devops-vg/app-data /mnt/app-data
df -h /mnt/app-data
```

### Task 6: Extend the Volume
```bash
lvextend -L +200M /dev/devops-vg/app-data
resize2fs /dev/devops-vg/app-data
df -h /mnt/app-data
```

---

## Documentation

Create `day-13-lvm.md` with:
- Commands used
- Screenshots of outputs
- What you learned (3 points)

---

## Submission
1. Add your `day-13-lvm.md` to `2026/day-13/`
2. Commit and push

---

## Learn in Public

Share your LVM progress on LinkedIn.

```
#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
```

Happy Learning!
**TrainWithShubham**
