# Day 26 – GitHub CLI: Manage GitHub from Your Terminal

## Task

Every time you switch to the browser to create a PR, check an issue, or manage a repo — you lose context. The **GitHub CLI (`gh`)** lets you do all of that without leaving your terminal. For DevOps engineers, this is essential — especially when you start automating workflows, scripting PR reviews, and managing repos at scale.

---

## Expected Output
- A markdown file: `day-26-notes.md` with your observations and answers
- Add `gh` commands to your `git-commands.md`

---

## Challenge Tasks

### Task 1: Install and Authenticate

**1. Install the GitHub CLI on your machine**

**commands to install GitHub CLI:**

--># Add GitHub CLI repo
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
| sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg

-->sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

-->echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
https://cli.github.com/packages stable main" \
| sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

-->sudo apt update

-->sudo apt install gh -y

-->To verify use command: gh --version

**2. Authenticate with your GitHub account**

-->To login to the GitHub account through cli use command: **gh auth login**

-->-->By providing access token loggedin successfully to the github account,

**During setup:** -->GitHub host → GitHub.com-->Protocol → HTTPS-->Authentication → Login via browser (recommended)

-->This opens a browser → you authorize → CLI gets access

<img width="1048" height="311" alt="image" src="https://github.com/user-attachments/assets/49dca828-3f5d-46b3-9b52-31139111f6f6" />

**3. Verify you're logged in and check which account is active**

-->**gh auth status**

<img width="1901" height="246" alt="image" src="https://github.com/user-attachments/assets/15542fe5-93bd-4042-a641-85fa26a5bd4b" />

**4. Answer in your notes: What authentication methods does `gh` support?**

-->GitHub CLI supports multiple authentication methods:

1. Browser-based OAuth (Recommended): **gh auth login**

-->Opens browser for secure login, No manual token handling, This is most secure & easiest

2. Personal Access Token (PAT): **gh auth login --with-token**

-->Then paste your token, Used in automation / servers, Requires token from GitHub settings, Good for CI/CD

3. SSH Authentication: **gh auth login**

-->Uses existing SSH keys, Useful if Git is already configured with SSH # choose SSH during prompts

4. Environment Variable (Automation): **export GITHUB_TOKEN=your_token**

-->Used in CI/CD pipelines (like GitHub Actions, Jenkins), No interactive login, Fully automated

---

### Task 2: Working with Repositories

1. Create a **new GitHub repo** directly from the terminal — make it public with a README -->**gh repo create my-new-repo --public --clone --add-readme**

2. Clone a repo using `gh` instead of `git clone`-->**gh repo clone sonali091023/portfolio**

<img width="878" height="223" alt="image" src="https://github.com/user-attachments/assets/62df59cc-8e9c-4335-8274-16cd0f9fca8a" />

3. View details of one of your repos from the terminal -->**gh repo view sonali091023/my-new-repo**

<img width="930" height="260" alt="image" src="https://github.com/user-attachments/assets/8ae8baf7-3d26-4c25-bec4-37b8c3830a4a" />

4. List all your repositories --> **gh repo list**

<img width="1892" height="752" alt="image" src="https://github.com/user-attachments/assets/b71122ce-3516-4768-b88f-d22230c056c7" />

  
6. Open a repo in your browser directly from the terminal--> **gh repo view sonali091023/my-new-repo --web**

-->To avoid installing heavy browsers in the terminal we can use this command as well, We will get the URL to launch the application in the browser: 

**gh repo view sonali091023/my-new-repo --json url -q .url**

<img width="912" height="52" alt="image" src="https://github.com/user-attachments/assets/ef102957-4ef2-47cb-aaa8-ae485ce9bf23" />

<img width="1832" height="852" alt="image" src="https://github.com/user-attachments/assets/c1763af7-e38c-45a2-baa9-5483aa81e031" />

8. Delete the test repo you created (be careful!) -->**gh repo delete sonali091023/my-new-repo**

<img width="945" height="132" alt="image" src="https://github.com/user-attachments/assets/ac6e8f86-b99a-4ee4-9dd1-75b778832518" />

---

### Task 3: Issues

1. Create an issue on one of your repos from the terminal — give it a title, body, and a label: Easier Interactive Way to create bug: **gh issue create**

-->It will ask: Title, Body, Labels

-->OR we can use command: gh issue create \
                          --repo sonali091023/my-new-repo \
                          --title "Bug: Login page not working" \
                          --body "Users are unable to log in after entering valid credentials. Needs investigation." \
                          --label "bug"

<img width="1162" height="255" alt="image" src="https://github.com/user-attachments/assets/fba371af-c830-405a-85da-26176c26cc70" />

3. List all open issues on that repo --> **gh issue list --repo sonali091023/my-new-repo**

<img width="806" height="182" alt="image" src="https://github.com/user-attachments/assets/68b51091-886b-4a6a-a388-3483f649da34" />

4. View a specific issue by its number -->**gh issue view 1 --json title,body,state**

<img width="1021" height="275" alt="image" src="https://github.com/user-attachments/assets/27109268-5c26-492f-8524-8697efc485b7" />

5. Close an issue from the terminal -->**gh issue close 1 --repo sonali091023/my-new-repo**

<img width="950" height="75" alt="image" src="https://github.com/user-attachments/assets/6a31ef80-72d5-4196-a3d6-a6ed5b4318d5" />

<img width="1352" height="532" alt="image" src="https://github.com/user-attachments/assets/badad590-9513-4c86-af68-e489dce3eafc" />

7. Answer in your notes: How could you use `gh issue` in a script or automation?

-->By combining gh issue commands in a script,you can automatically: Check open issues, Add comments, Close issues etc.

-->Example: gh issue list --repo srdangat/gh-cli-task-day26
 
           gh issue comment 1 --repo srdangat/gh-cli-task-day26 --body "Checked automatically."
           
           gh issue close 1 --repo srdangat/gh-cli-task-day26

---

### Task 4: Pull Requests
1. Create a branch, make a change, push it, and create a **pull request** entirely from the terminal

-->Commands: 
             
             gh repo clone sonali091023/my-new-repo
             
             cd my-new-repo

             git init

             touch file{1..3}

             ls

             git status

             git add .

             git commit -m "new file added"

             git push origin main

<img width="1895" height="373" alt="image" src="https://github.com/user-attachments/assets/d82f0597-1cf2-486b-8dc1-d9660131e103" />

<img width="1363" height="803" alt="image" src="https://github.com/user-attachments/assets/237b409f-162c-4f80-802d-87026348e37d"/>

<img width="1505" height="622" alt="image" src="https://github.com/user-attachments/assets/367d9830-8323-4bd7-97ab-64d52f8cf790" />

2. List all open PRs on a repo --> **gh pr list --repo sonali091023/test-day-26**

<img width="777" height="150" alt="image" src="https://github.com/user-attachments/assets/cc0d493c-575c-4bf9-8ad0-cef76a00fd1b" />


3. View the details of your PR — check its status, reviewers, and checks -->**gh pr view 1 --json state,reviewRequests,statusCheckRollup**

<img width="907" height="141" alt="image" src="https://github.com/user-attachments/assets/f4d31fba-91c4-4d75-aa09-89531b1b323b" />

6. Merge your PR from the terminal-->**gh pr merge 1 --repo sonali091023/test-day-26**

<img width="926" height="168" alt="image" src="https://github.com/user-attachments/assets/3db5f309-9a0f-4a57-a99c-bfaf76231523" />

<img width="1412" height="701" alt="image" src="https://github.com/user-attachments/assets/6c7501dc-7044-4b1b-bba3-e687b4ba08bf" />


8. Answer in your notes:

**What merge methods does gh pr merge support?**

-->Merge Commit, Squash and Merge, Rebase and Merge

**How would you review someone else's PR using gh?**

-->gh pr review <PR-number>

---

### Task 5: GitHub Actions & Workflows (Preview)

1. List the workflow runs on any public repo that uses GitHub Actions -->**gh pr merge 1 --repo sonali091023/test-day-26**

<img width="1655" height="455" alt="image" src="https://github.com/user-attachments/assets/a377b3fe-2469-4390-82ea-fb29de064d06" />

2. View the status of a specific workflow run -->**gh run view 24304428455 --repo cli/cli --json status,conclusion**

<img width="1901" height="528" alt="image" src="https://github.com/user-attachments/assets/84fd662b-4bfb-4b0e-a341-f0bba68c14d0" />
 
3. Answer in your notes: How could `gh run` and `gh workflow` be useful in a CI/CD pipeline?

-->They enable you to control and automate GitHub Actions programmatically,allowing you to start, track and manage workflows directly from scripts without needing manual interaction

(Don't worry if you haven't learned GitHub Actions yet — this is a preview for upcoming days)

---

### Task 6: Useful `gh` Tricks

Explore and try these — add the ones you find useful to your `git-commands.md`:

**1. `gh api` — make raw GitHub API calls from the terminal**

-->Make direct GitHub API calls, Used for automation & fetching data **Eg: gh api repos/cli/cli/issues**

**2. `gh gist` — create and manage GitHub Gists**

-->Create & manage GitHub Gists, Share code snippets or logs **Eg: gh gist create file.txt --public**

**3. `gh release` — create and manage releases**

-->Create & manage releases, Publish versions of your project **Eg: gh release create v1.0.0 -t "First Release"**

**4. `gh alias` — create shortcuts for commands you use often**

-->Create custom shortcuts, Save time on repeated commands **Eg: gh alias set co "pr checkout"**

**5. `gh search repos` — search GitHub repos from the terminal**

-->Search GitHub repositories, Discover tools & projects **Eg: gh search repos devops --stars >1000**

---

## Hints
- `gh help` and `gh <command> --help` are your best friends
- Most `gh` commands work with `--repo owner/repo` to target a specific repo
- Use `--json` flag with most commands to get machine-readable output (useful for scripting)
- `gh pr create --fill` auto-fills the PR title and body from your commits

---

## Submission
1. Add your `day-26-notes.md` to `2026/day-26/`
2. Update `git-commands.md` with `gh` commands — this completes your Git & GitHub reference from Days 22–26
3. Push to your fork

---

## Learn in Public

Share your favorite `gh` commands or a screenshot of creating a PR from the terminal on LinkedIn.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
