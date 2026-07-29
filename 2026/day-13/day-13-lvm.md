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

---

### Task 2: Create Physical Volume
```bash
pvcreate /dev/sdb   # or your loop device
pvs
```
**Steps to follow:**

-->Note: Do NOT run pvcreate /dev/sdb on your machine.

<img width="671" height="300" alt="image" src="https://github.com/user-attachments/assets/ab6008c2-b256-4792-91aa-d0c40f673115" />

Q. What is pvcreate?
-->pvcreate initializes a storage device so that LVM can manage it.
<img width="712" height="405" alt="image" src="https://github.com/user-attachments/assets/2fb569d4-d569-4e1a-84d3-8880aa947d0f" />

Q. What is a Physical Volume (PV)?
-->A Physical Volume is the first building block of LVM.
<img width="707" height="407" alt="image" src="https://github.com/user-attachments/assets/4516de8c-5745-45a3-baaa-00528c96e25d" />

**Example:**

<img width="700" height="621" alt="image" src="https://github.com/user-attachments/assets/d2d6c107-771f-4230-83c0-ca787a4128e4" />

Q. What does pvs do?

-->After creating the PV: pvc

<img width="707" height="415" alt="image" src="https://github.com/user-attachments/assets/ca488248-7c3f-44ce-bb99-8e735004aea7" />

Q. Why is it called a "Physical Volume"?

<img width="721" height="362" alt="image" src="https://github.com/user-attachments/assets/5362633f-00be-4363-b28d-befa91e8844c" />

Your current situation: That's completely normal because you haven't created an LVM disk yet.

<img width="692" height="407" alt="image" src="https://github.com/user-attachments/assets/26b45e28-3a52-4e10-ab93-e195b9ecacdc" />

### Task 3: Create Volume Group
```bash
vgcreate devops-vg /dev/sdb
vgs
```
**Steps to follow:**

-->This is the next step in the LVM hierarchy, but don't execute it on your current WSL system until you have a dedicated empty disk or loop device.

Q. What is a Volume Group (VG)?

-->A Volume Group is a pool of storage created from one or more Physical Volumes (PVs).

<img width="792" height="722" alt="image" src="https://github.com/user-attachments/assets/69f23914-ba2e-4f52-906b-4c77adb3be8f" />

-->Now create one Volume Group: vgcreate devops-vg /dev/sdb /dev/sdc /dev/sdd [Note: Instead of thinking about three separate disks, LVM now sees one 600 GB storage pool.]

Understanding the command: vgcreate devops-vg /dev/sdb

<img width="777" height="712" alt="image" src="https://github.com/user-attachments/assets/c2f6b31d-f406-40bc-8cff-3d5705e810a1" />

Q. What happens internally?

<img width="767" height="462" alt="image" src="https://github.com/user-attachments/assets/59913524-d1d1-4afd-ae03-bf1ae89b7549" />

Checking the Volume Group: vgs

<img width="816" height="632" alt="image" src="https://github.com/user-attachments/assets/a33a5e78-41d6-42c3-8f94-01a0d2e10c0a" />

The complete LVM flow:
~~~
Step 1
Disk
   │
   ▼
/dev/loop0

Step 2
pvcreate

   │
   ▼
Physical Volume (PV)

Step 3
vgcreate devops-vg

   │
   ▼
Volume Group (VG)

Step 4
lvcreate

   │
   ▼
Logical Volume (LV)

Step 5
mkfs.ext4

   │
   ▼
Filesystem

Step 6
mount

   │
   ▼
/mnt/storage
~~~

Important for your environment:

<img width="816" height="512" alt="image" src="https://github.com/user-attachments/assets/87f8768d-cb3c-4999-947f-48c97f3e5f64" />

-->Those commands are only safe when /dev/sdb is an empty disk dedicated to the lab. In your WSL environment, /dev/sdb is an existing system disk, not the extra virtual disk the assignment expects.

-->Recommended next step: Before proceeding with pvcreate and vgcreate, let's verify whether your WSL instance supports loop devices. Please run: losetup -a & losetup -a

---

### Task 4: Create Logical Volume
```bash
lvcreate -L 500M -n app-data devops-vg
lvs
```
**Steps to follow:**

-->This is Task 4 in the LVM workflow: creating a Logical Volume (LV). Again, do not run this command on your current WSL setup until you have successfully created a Physical Volume (PV) and Volume Group (VG) on a dedicated empty disk or loop device.

LVM hierarchy so far: A Logical Volume is similar to a normal disk partition, except it is created inside a Volume Group.

<img width="792" height="537" alt="image" src="https://github.com/user-attachments/assets/e7313ea4-56f8-4970-83df-9723d3d8967b" />

Understanding the command: lvcreate -L 500M -n app-data devops-vg

<img width="780" height="547" alt="image" src="https://github.com/user-attachments/assets/91630f3c-581c-4571-9de5-f30348f78c79" />

<img width="802" height="762" alt="image" src="https://github.com/user-attachments/assets/a6015d1c-0dc9-45e5-a2c9-0c98fb4bd5a2" />

Checking the result: After creating the LV: lvs

<img width="802" height="450" alt="image" src="https://github.com/user-attachments/assets/9b3fb38a-67ce-4ade-b05a-09ee3c110ad1" />

Q. Where is the Logical Volume?

<img width="801" height="312" alt="image" src="https://github.com/user-attachments/assets/4a8a8067-513c-4b50-8ca4-4211412c2283" />

Next steps after lvcreate: Normally, the workflow continues like this:

1. Create a filesystem: mkfs.ext4 /dev/devops-vg/app-data

2. Create a mount point: mkdir /mnt/app-data

3. Mount it: mount /dev/devops-vg/app-data /mnt/app-data

4. verify: df -h

Complete LVM flow:

```
Empty Disk
    │
    ▼
pvcreate
    │
    ▼
Physical Volume (PV)
    │
    ▼
vgcreate
    │
    ▼
Volume Group (VG)
    │
    ▼
lvcreate
    │
    ▼
Logical Volume (LV)
    │
    ▼
mkfs.ext4
    │
    ▼
Filesystem
    │
    ▼
mount
    │
    ▼
Ready to store files
```

Important for your WSL environment:

<img width="850" height="710" alt="image" src="https://github.com/user-attachments/assets/e1895dda-13f8-46b9-ad95-b6661da96cc5" />

---

### Task 5: Format and Mount
```bash
mkfs.ext4 /dev/devops-vg/app-data
mkdir -p /mnt/app-data
mount /dev/devops-vg/app-data /mnt/app-data
df -h /mnt/app-data
```

**Steps to follow:**

-->This is the final step of the LVM setup. Up to this point, you've only created storage structures. In Task 5, you create a filesystem on the Logical Volume and make it usable by mounting it.

-->Important: Based on your earlier outputs, your WSL environment does not currently have the required devops-vg Volume Group or app-data Logical Volume. So these commands are for understanding the process and should only be run after Tasks 2–4 have completed successfully on a dedicated empty disk.

Step 1: Create a filesystem: mkfs.ext4 /dev/devops-vg/app-data

Q. What is mkfs?

-->mkfs means Make File System.
<img width="775" height="552" alt="image" src="https://github.com/user-attachments/assets/82a8de29-263d-4a01-9ab6-d5f74c8757ca" />

Q. Why ext4?

-->ext4 is the default Linux filesystem because it is:
- Stable
- Fast
- Reliable
- Supports large files and volumes
- Commonly used on Linux servers

Step 2: Create a mount point: mkdir -p /mnt/app-data [Note: This creates a directory where the filesystem will be attached.]

<img width="762" height="470" alt="image" src="https://github.com/user-attachments/assets/1acbe6c3-7514-48ad-a808-36551dfbf4ed" />

Step 3: Mount the Logical Volume: mount /dev/devops-vg/app-data /mnt/app-data

<img width="775" height="686" alt="image" src="https://github.com/user-attachments/assets/c06cd9fc-f6b1-4e76-bb8f-12be04b58f36" />

Step 4: Verify: df -h /mnt/app-data

<img width="767" height="557" alt="image" src="https://github.com/user-attachments/assets/a70edb05-ef92-430b-809c-d238b9e9c190" />

Complete LVM workflow:
~~~
Empty Disk
    │
    ▼
pvcreate
    │
    ▼
Physical Volume (PV)
    │
    ▼
vgcreate
    │
    ▼
Volume Group (VG)
    │
    ▼
lvcreate
    │
    ▼
Logical Volume (LV)
    │
    ▼
mkfs.ext4
    │
    ▼
Filesystem
    │
    ▼
mount
    │
    ▼
/mnt/app-data
~~~

Q. What if you skip mkfs?

-->If you try to mount an unformatted Logical Volume: mount /dev/devops-vg/app-data /mnt/app-data

<img width="751" height="146" alt="image" src="https://github.com/user-attachments/assets/d3c0a4c8-1532-419e-a648-662dfb6bb83a" />

Your current WSL situation:

<img width="807" height="360" alt="image" src="https://github.com/user-attachments/assets/1307f887-c4cb-444e-a240-9cf9fd9ba55b" />

Summary of the full assignment:

<img width="872" height="372" alt="image" src="https://github.com/user-attachments/assets/8cf0eb31-9ea0-4367-b042-1ad033e9ebfb" />

---

### Task 6: Extend the Volume
```bash
lvextend -L +200M /dev/devops-vg/app-data
resize2fs /dev/devops-vg/app-data
df -h /mnt/app-data
```

**Steps to follow:**

-->Excellent! Task 6 demonstrates one of the biggest advantages of LVM: you can increase storage without recreating the filesystem or repartitioning the disk.

-->Note: In your current WSL setup, you don't yet have the devops-vg Volume Group or the app-data Logical Volume, so these commands are for learning. They will only work after Tasks 2–5 have been completed on a dedicated LVM disk.

lvextend -L +200M /dev/devops-vg/app-data
resize2fs /dev/devops-vg/app-data
df -h /mnt/app-data

Step 1: Extend the Logical Volume: lvextend -L +200M /dev/devops-vg/app-data

Q. What does this command do?

-->It increases the size of the Logical Volume by 200 MB.

Let's break it down:
- lvextend → Extends an existing Logical Volume.
- -L +200M → Add 200 MB to the current size.
- The + is important because it means increase by 200 MB.
- Without the +, LVM sets the total size.

For example: lvextend -L +200M /dev/devops-vg/app-data

<img width="817" height="315" alt="image" src="https://github.com/user-attachments/assets/ad9786ea-9e62-4aea-9fe3-0cafac547b7c" />

Before and after:

<img width="765" height="445" alt="image" src="https://github.com/user-attachments/assets/ceae8e82-f412-4143-a67b-9fefa008fca7" />

Step 2: Resize the filesystem: resize2fs /dev/devops-vg/app-data

<img width="790" height="662" alt="image" src="https://github.com/user-attachments/assets/f771f473-45af-4efd-be23-3f18bd95f26d" />

Step 3: Verify the new size: df -h /mnt/app-data

<img width="810" height="307" alt="image" src="https://github.com/user-attachments/assets/5e48dc9d-3fba-4e34-90cc-606e19ce094b" />

Q. Why resize2fs is needed?
-->Think of it like this:

<img width="682" height="821" alt="image" src="https://github.com/user-attachments/assets/f2b2b160-975e-48f2-8ed2-be513e903c64" />

Real-world example:

<img width="737" height="556" alt="image" src="https://github.com/user-attachments/assets/6ab71ba4-e344-4a59-a6cc-8715cbb634c9" />

Complete LVM workflow: 
~~~
Disk
 │
 ▼
pvcreate
 │
 ▼
Physical Volume (PV)
 │
 ▼
vgcreate
 │
 ▼
Volume Group (VG)
 │
 ▼
lvcreate
 │
 ▼
Logical Volume (LV)
 │
 ▼
mkfs.ext4
 │
 ▼
mount
 │
 ▼
/mnt/app-data
 │
 ▼
lvextend
 │
 ▼
resize2fs
 │
 ▼
Larger filesystem without changing the mount point
~~~

Important for your environment: From the outputs you shared earlier:
- pvs → empty
- vgs → empty
- lvs → empty

So running: lvextend -L +200M /dev/devops-vg/app-data

-->right now would fail because the Logical Volume doesn't exist yet, For your assignment, the correct order is:
- Check storage (lsblk, pvs, vgs, lvs, df -h)
- Create a Physical Volume (PV)
- Create a Volume Group (VG)
- Create a Logical Volume (LV)
- Format and mount it
- Extend the LV and resize the filesystem

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
