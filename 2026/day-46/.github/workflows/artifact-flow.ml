name: Artifact Flow

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Generate file
        run: |
          mkdir output               
          echo "Hello from Job 1" > output/message.txt     #Creates file → output/message.txt

      - name: Upload artifact                              #Uploads it as artifact → my-artifact
        uses: actions/upload-artifact@v4
        with:
          name: my-artifact
          path: output/message.txt

  consume:
    runs-on: ubuntu-latest
    needs: build                                           #Important: ensures Job 1 runs first

    steps:
      - name: Download artifact                            #Downloads artifact, GitHub automatically extracts it, File becomes available in working directory
        uses: actions/download-artifact@v4
        with:
          name: my-artifact

      - name: Print file content
        run: |
          echo "Contents of file:"
          cat message.txt
