## Task 2: Hello Workflow

- Workflow file: `.github/workflows/hello.yml`
- Trigger: Every push (`on: push`)
- Job name: `greet`
- Runner: `ubuntu-latest`
- Step 1: Checks out the repository using `actions/checkout@v4`
- Step 2: Prints "Hello from GitHub Actions!"
- Result: Workflow completed successfully (green check mark).

## Task 4: Add More Steps

I updated the workflow to:
- Print "Hello from GitHub Actions!"
- Print the current date and time using the `date` command.
- Print the branch name using `${{ github.ref_name }}`.
- List all files in the repository using `ls -la`.
- Print the runner operating system using the `$RUNNER_OS` environment variable.

After pushing the changes, the workflow ran successfully, and I verified the output of each step in the GitHub Actions logs.

## Task 5: Break It On Purpose

### What does a failed pipeline look like?

- The workflow shows a red ❌ in the Actions tab.
- The job containing the failed step is marked as failed.
- The specific step that failed is highlighted with a red X.
- Any steps after the failure are skipped and do not run.

### How do you read the error?

- Open the failed workflow run in the Actions tab.
- Click the failed job.
- Open the step marked with the red X.
- Read the log to see:
  - The command that was executed.
  - The error message.
  - The exit code (for example, `Process completed with exit code 1`).

The logs help identify which command failed and why, making it easier to fix the workflow.
