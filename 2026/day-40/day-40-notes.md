## Task 2: Hello Workflow

- Workflow file: `.github/workflows/hello.yml`
- Trigger: Every push (`on: push`)
- Job name: `greet`
- Runner: `ubuntu-latest`
- Step 1: Checks out the repository using `actions/checkout@v4`
- Step 2: Prints "Hello from GitHub Actions!"
- Result: Workflow completed successfully (green check mark).
