# Task 2 – Multi-Stage Build

## Image Comparison

| Image | Size |
|-------|------|
| hello-node-single |  1.1GB |
| hello-node-multi  |  136MB |

<img width="1912" height="125" alt="image" src="https://github.com/user-attachments/assets/f1ea8879-8e3a-47ae-b13a-a23192a9c857" />

## Why is the multi-stage image smaller?

- The build process is isolated in a separate stage.
- Only the application files and production dependencies are copied to the final image.
- Build caches and temporary files are excluded.
- The final image uses a lightweight Alpine-based Node.js image.
- Smaller images are faster to pull, require less storage, and improve security by reducing the attack surface.

## Conclusion

Multi-stage builds create cleaner, more efficient Docker images by separating the build environment from the runtime environment.
