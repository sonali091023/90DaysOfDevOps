# Day 38 – YAML Basics

## Task
Before writing a single CI/CD pipeline, you need to get comfortable with **YAML** — the language every pipeline is written in.

You will:
- Understand YAML syntax and rules
- Write YAML files by hand
- Validate them

---

## Expected Output
- A markdown file: `day-38-yaml.md`
- YAML files you create during the tasks

---

## Challenge Tasks

### Task 1: Key-Value Pairs
Create `person.yaml` that describes yourself with:
- `name`
- `role`
- `experience_years`
- `learning` (a boolean)

**Verify:** Run `cat person.yaml` — does it look clean? No tabs?

<img width="1010" height="256" alt="image" src="https://github.com/user-attachments/assets/075fe51c-4490-4d00-8006-cd1b190d8007" />

---

### Task 2: Lists
Add to `person.yaml`:
- `tools` — a list of 5 DevOps tools you know or are learning
- `hobbies` — a list using the inline format `[item1, item2]`

Write in your notes: What are the two ways to write a list in YAML?

-->There are two ways to write a list in YAML:

**1. Block format (multi-line)**

tools:

  - Docker
  
  - Kubernetes
  
  - Jenkins

**2. Inline format (single-line): hobbies: [reading, coding]**

<img width="1028" height="280" alt="image" src="https://github.com/user-attachments/assets/79d808ae-6e09-41cd-891c-42e36a90f073" />

---

### Task 3: Nested Objects
Create `server.yaml` that describes a server:
- `server` with nested keys: `name`, `ip`, `port`
- `database` with nested keys: `host`, `name`, `credentials` (nested further: `user`, `password`)

**Verify:** Try adding a tab instead of spaces — what happens when you validate it?

-->If we add a tab instead of spaces, YAML will break for example:

server:

    name: my-server

-->Instead Always use 2 spaces (common convention), YAML only allows spaces for indentation

<img width="1012" height="333" alt="image" src="https://github.com/user-attachments/assets/e060cd0e-4587-40a3-b404-c4fc5b52fe38" />

---

### Task 4: Multi-line Strings
In `server.yaml`, add a `startup_script` field using:
1. The `|` block style (preserves newlines)
2. The `>` fold style (folds into one line)

Write in your notes: When would you use `|` vs `>`?

--> **| (literal block style)** → preserves line breaks exactly

--> **> (folded style)** → converts newlines into spaces 

-->**Use | when:** Writing scripts (bash, shell commands), Formatting must stay exactly the same, Multi-line configs or logs

-->**Use > when:** Writing long text (descriptions, messages), You want cleaner YAML but don’t care about line breaks, Lines should behave as a single paragraph

<img width="1012" height="530" alt="image" src="https://github.com/user-attachments/assets/38b88200-6019-4c23-90ad-70c09b12d927" />

### Task 5: Validate Your YAML
1. Install `yamllint` or use an online validator

-->sudo apt update

-->sudo apt install yamllint -y

2. Validate both your YAML files

<img width="1067" height="302" alt="image" src="https://github.com/user-attachments/assets/097720a4-09cd-4d95-97d6-9e795c8d724e" />

3. Intentionally break the indentation — what error do you get?

<img width="1067" height="302" alt="image" src="https://github.com/user-attachments/assets/46fe02e0-f3e5-4de5-9632-78e3dbcd0801" />

5. Fix it and validate again

<img width="1067" height="302" alt="image" src="https://github.com/user-attachments/assets/306d4512-fe9d-4780-a9c0-9c74cc39c0c6" />

---

### Task 6: Spot the Difference
Read both blocks and write what's wrong with the second one:

```yaml
# Block 1 - correct
name: devops
tools:
  - docker
  - kubernetes
```

```yaml
# Block 2 - broken
name: devops
tools:
- docker
  - kubernetes
```

-->The issue in Block 2 is incorrect indentation of the list under tools, - docker is not indented, so YAML may interpret it as a top-level list item, 
not part of tools, And - kubernetes is indented differently, making the list inconsistent.

-->YAML requires consistent indentation for all list items under a key.

**Correct version**

tools:
  - docker
  - kubernetes
---

## Hints
- YAML uses **spaces only** — never tabs
- Indentation is everything — 2 spaces is standard
- Strings don't need quotes unless they contain special characters (`:`, `#`, etc.)
- `true`/`false` are booleans, `"true"` is a string
- Validate online: yamllint.com

---

## Documentation
Create `day-38-yaml.md` with:
- Your YAML files
- What you learned (3 key points)

---

## Submission
1. Add your YAML files and `day-38-yaml.md` to `2026/day-38/`
2. Commit and push to your fork

---

## Learn in Public
Share your YAML "aha moment" on LinkedIn — the tab vs space mistake gets everyone.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
