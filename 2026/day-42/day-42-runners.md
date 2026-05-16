# Day 42 – Runners: GitHub-Hosted & Self-Hosted

## Task
Every job needs a machine to run on. Today you understand **runners** — GitHub's hosted ones and how to set up your own self-hosted runner on a real server.

---

## Expected Output
- A self-hosted runner registered to your GitHub repo
- A workflow that runs a job on your self-hosted runner
- A markdown file: `day-42-runners.md`

---

## Challenge Tasks

### Task 1: GitHub-Hosted Runners
1. Create a workflow with 3 jobs, each on a different OS:
   - `ubuntu-latest`
   - `windows-latest`
   - `macos-latest`
2. In each job, print:
   - The OS name
   - The runner's hostname
   - The current user running the job
3. Watch all 3 run in parallel

-->**Github repository used:** https://github.com/sonali091023/github-actions-practice/tree/main/.github/workflows

<img width="1916" height="807" alt="image" src="https://github.com/user-attachments/assets/eecad835-3ec1-407c-a3f5-f2be6cefaeeb" />

<img width="1883" height="852" alt="image" src="https://github.com/user-attachments/assets/b7de0613-eebe-4493-8e6c-c1d29f1e2151" />

<img width="1910" height="835" alt="image" src="https://github.com/user-attachments/assets/477839b0-109f-4678-b5af-dab27807ed91" />

-->First of all we can see different syntax for Linux/macOS → Bash ($(hostname)) & Windows → CMD (%COMPUTERNAME%) & If you try Linux commands on Windows it will fail.

Write in your notes: What is a GitHub-hosted runner? Who manages it?

-->All 3 jobs for ubuntu, windows & macos run in parallel, Each job runs on a different machine, **A GitHub-hosted runner is A temporary virtual machine provided by GitHub to run your workflows**, Key Characteristics of gitHub hosted runners are Fresh VM every run, Pre-installed tools (Node, Python, Docker, etc.), Automatically destroyed after job finishes,
No manual setup required. And if you want to see the parallel execution of each job then add the delay of 10 seconds like sleep 10.

-->GitHub manages everything That includes Infrastructure (servers), OS setup, Security patches, Scaling we just write YAML — GitHub handles execution.

-->Github hosted runner is matter because it handles Multi-environment testing, Cross-platform compatibility, Parallel job execution, Runner abstraction (VERY important concept) etc.

---

### Task 2: Explore What's Pre-installed
1. On the `ubuntu-latest` runner, run a step that prints:
   - Docker version
   - Python version
   - Node version
   - Git version
2. Look up the GitHub docs for the full list of pre-installed software on `ubuntu-latest`

-->if search for "**ubuntu-latest installed software github actions**" then we can get the full list of pre-installed software on ubuntu-late0st.

<img width="1852" height="912" alt="image" src="https://github.com/user-attachments/assets/e254e446-c14e-41fe-8b89-410d74c38e3e" />

<img width="1892" height="891" alt="image" src="https://github.com/user-attachments/assets/973750bb-3a85-4ee6-9dc4-be4ce0b5912b" />

-->When this runs on ubuntu-latest, GitHub gives you a ready VM that already has installed Docker, Python, Node.js, Git etc. 

Write in your notes: Why does it matter that runners come with tools pre-installed?

-->This is matters more because of Faster execution of the pipelines, No need to install tools every time, Saves minutes on every run, Huge impact in large CI/CD systems

-->It has Consistency Every run uses the same environment, so more we have to face issue like No “it works on my machine”.

-->In github hosted runner there is Less setup complexity, No need to write installation scripts, Cleaner YAML, Easier maintenance.

-->It has Reliability that Tools are tested and maintained by GitHub, So there is Less chance of broken installs.

**Note:** Pre-installed tools in GitHub-hosted runners reduce setup time, improve consistency, and simplify CI/CD pipelines. However, since tool versions can change, it’s important to explicitly define versions when stability is required.

---

### Task 3: Set Up a Self-Hosted Runner
1. Go to your GitHub repo → Settings → Actions → Runners → **New self-hosted runner**
2. Choose Linux as the OS & Architecture
-->GitHub will now show you a set of commands — we’ll execute them on your machine.
3. Follow the instructions to download and configure the runner on:
   - Your local machine, OR
   - A cloud VM (EC2, Utho, or any VPS)

**Instructions As follow to Download:**

# Create a folder--> $ mkdir actions-runner && cd actions-runnerCopied!

# Download the latest runner package--> $ curl -o actions-runner-linux-x64-2.333.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.333.1/actions-runner-linux-x64-2.333.1.tar.gzCopied!# Optional: Validate the hash

--> $ echo "18f8f68ed1892854ff2ab1bab4fcaa2f5abeedc98093b6cb13638991725cab74  actions-runner-linux-x64-2.333.1.tar.gz" | shasum -a 256 -c# Extract the installer

--> **Extract:** $ tar xzf ./actions-runner-linux-x64-2.333.1.tar.gz

**Run the following commands to Configure the runner:**

# Create the runner and start the configuration experience--> $ ./config.sh --url https://github.com/sonali091023/github-actions-practice --token B2WSPIGSBSMP3WED4Y5KEDTJ5DKYM# Last step, run it!

--> **Start the Runner:** --> $ ./run.sh

<img width="1916" height="985" alt="image" src="https://github.com/user-attachments/assets/53f80016-81fb-41f7-bb14-46984c757c66" />

**Command to Use your self-hosted runner:** Use this YAML in your workflow file for each job--> **runs-on: self-hosted**

4. Start the runner — verify it shows as **Idle** in GitHub

**Verify:** Your runner appears in the Runners list with a green dot.

<img width="1867" height="817" alt="image" src="https://github.com/user-attachments/assets/d34a04df-b479-4771-a4f7-26308a0db623" />

---

### Task 4: Use Your Self-Hosted Runner
1. Create `.github/workflows/self-hosted.yml`
2. Set `runs-on: self-hosted`
3. Add steps that:
   - Print the hostname of the machine (it should be YOUR machine/VM)
   - Print the working directory
   - Create a file and verify it exists on your machine after the run
4. Trigger it and watch it run on your own hardware

<img width="972" height="810" alt="image" src="https://github.com/user-attachments/assets/aa440878-172f-4e51-aa4f-042ca60f586e" />

<img width="1895" height="840" alt="image" src="https://github.com/user-attachments/assets/b75d42a7-8f9b-45f4-9804-81928bcb908e" />

**Verify:** Check your machine — is the file there?

-->File got created at following location: **cd actions-runner/_work/<repo-name>/<repo-name>** then do **ls** there we can see the created file vi self hosted runner. And when we open it vi cat command we can see the content inside as well

<img width="1903" height="673" alt="image" src="https://github.com/user-attachments/assets/f9332cfd-97d5-44e8-a5e8-3b21fa6f1623" />

-->So What just happened is GitHub sent the job to your runner, Your machine executed the commands & The file was created locally on your system, So this proves Self-hosted runner = your machine acting as a CI server.

---

### Task 5: Labels
1. Add a **label** to your self-hosted runner (e.g., `my-linux-runner`)
2. Update your workflow to use `runs-on: [self-hosted, my-linux-runner]`
3. Trigger it — does it still pick up the job?

-->Yes, Labels help GitHub select the correct machine for a workflow when multiple self-hosted runners exist.

Write in your notes: Why are labels useful when you have multiple self-hosted runners?

-->Target specific machines Example: Docker machine, GPU machine, Production deployment machine etc.

**Eg:** like runs-on: [self-hosted, gpu] --> Only runners with GPU pick the job.

-->With the self-hosted runner we get Better scalability like Large companies may have 10 Linux runners, 5 Windows runners, 2 deployment servers all this organize by label.

<img width="1902" height="892" alt="image" src="https://github.com/user-attachments/assets/cca6e158-8323-4930-aba2-fb01e7cba9ee" />

---

### Task 6: GitHub-Hosted vs Self-Hosted
Fill this in your notes:

| | GitHub-Hosted | Self-Hosted |
|---|---|---|
| Who manages it? | Github | You (your team / your infra) |
| Cost | Free tier + paid minutes | You pay for your machine (VM/local/server) |
| Pre-installed tools | Yes (Docker, Node, Python, Git, etc.) | Depends on you (you install & maintain) |
| Good for | Quick setup, standard CI/CD, beginners, general workloads | Custom environments, private network access, heavy workloads |
| Security concern | Safer by default (ephemeral VMs, auto-cleaned) | Higher risk if misconfigured (persistent machine, needs hardening) |

-->**Note:** GitHub-hosted runners are ideal for standardized, scalable CI pipelines, while self-hosted runners are preferred when workflows require custom dependencies, access to internal resources, or specialized hardware.

---

## Hints
- Runner setup script is generated by GitHub — just copy and run it
- Self-hosted runner runs as a background service: `./run.sh`
- To run as a service (persistent): `sudo ./svc.sh install && sudo ./svc.sh start`
- `runs-on: self-hosted` targets any self-hosted runner
- `runs-on: [self-hosted, linux, my-label]` targets specific ones

---

## Documentation
Create `day-42-runners.md` with:
- Screenshot of your self-hosted runner showing as Idle in GitHub
- Screenshot of a job running on your self-hosted runner
- The comparison table from Task 6

---

## Submission
1. Add `day-42-runners.md` to `2026/day-42/`
2. Commit and push to your fork

---

## Learn in Public
Share your self-hosted runner screenshot on LinkedIn — running CI on your own machine is a cool flex.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
