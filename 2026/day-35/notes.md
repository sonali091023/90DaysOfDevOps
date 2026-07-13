# Task 1 – The Problem with Large Images

## Single Stage Build

Image Name: hello-node-single:latest

```
hello-node-single
```

Image Size: 1.1GB

```
<img width="1521" height="157" alt="image" src="https://github.com/user-attachments/assets/5b578913-d57e-46e3-b254-f9189de3ace0" />

```

Observation:

- Image contains the Node runtime and build tools.
- All build dependencies remain in the final image.
- Image is larger than necessary for a simple Hello World application.
- This serves as the baseline for comparison with a multi-stage build.
