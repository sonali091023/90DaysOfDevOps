# Git Commands Reference

## Setup & Config

### git --version

**What it does:**
Displays the installed Git version.

**Example:**
```bash
git --version
```

---

### git config --global user.name "Your Name"

**What it does:**
Sets your Git username for all repositories.

**Example:**
```bash
git config --global user.name "Sonali"
```

---

### git config --global user.email "your-email@example.com"

**What it does:**
Sets your Git email address for all repositories.

**Example:**
```bash
git config --global user.email "sonali@example.com"
```

---

### git config --global --list

**What it does:**
Displays all global Git configuration settings.

**Example:**
```bash
git config --global --list
```

---

## Basic Workflow

### git init

**What it does:**
Creates a new Git repository in the current directory.

**Example:**
```bash
git init
```

---

### git status

**What it does:**
Shows the current state of the repository, including tracked and untracked files.

**Example:**
```bash
git status
```

---

## Viewing Changes

### ls -la

**What it does:**
Lists all files, including hidden files like `.git`.

**Example:**
```bash
ls -la
```

---

### cd .git

**What it does:**
Moves into the hidden Git metadata directory.

**Example:**
```bash
cd .git
```

---

### cat HEAD

**What it does:**
Shows which branch `HEAD` is currently pointing to.

**Example:**
```bash
cat HEAD
```

---

### pwd

**What it does:**
Displays the current working directory.

**Example:**
```bash
pwd
```

## Viewing Changes

### git diff

**What it does:**
Shows the changes that have not yet been staged.

**Example:**

```bash
git diff
```

---

### git diff --staged

**What it does:**
Shows changes that have been staged but not yet committed.

**Example:**

```bash
git diff --staged
```

### git log

**What it does:**
Displays the commit history.

**Example:**

```bash
git log
```

---

### git log --oneline

**What it does:**
Shows commit history in a compact one-line format.

**Example:**

```bash
git log --oneline
```


