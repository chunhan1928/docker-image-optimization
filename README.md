# Docker Image Optimization Demo

This project demonstrates a fundamental principle of Docker optimization: **efficient layer caching**.

Although this project uses Python as an example, you don't need to understand Python at all (there are only two lines of code). The most important lesson here is about **preventing resource waste on unchanged components**. This principle applies to any project in any programming language.

> **Core Concept**: When building Docker images, always structure your Dockerfile to maximize layer caching. This means:
>
> - Place frequently changing files (like application code) at the end
> - Place rarely changing files (like dependency lists) at the beginning
> - Separate dependency installation from code copying

## Step 1: Build and Run the Images

### Build the Images

```bash
# Build the unoptimized image
docker image build -f bad.Dockerfile -t random-number:bad .

# Build the optimized image
docker image build -f optimized.Dockerfile -t random-number:opt .
```

### Run the Containers

```bash
# Run the unoptimized container
docker container run random-number:bad

# Run the optimized container
docker container run random-number:opt
```

> **Note**: At this point, both containers will behave identically. The key difference lies in how they handle code changes and rebuilds.

## Step 2: Modify `main.py` and Rebuild

Let's modify `main.py` to demonstrate the power of Docker layer caching:

```python
import numpy as np

print(np.random.randint(1, 1000))
```

### Observe the Build Process

When you rebuild the images, pay close attention to the build logs:

#### Unoptimized Build (bad.Dockerfile)

- **Problem**: Since the entire directory content changes, the `COPY . .` layer and all subsequent layers (including `pip install`) must be rebuilt
- **Consequence**: Requires internet access and time to re-download all dependencies, even though they haven't changed
- **Build Time**: ~6.3 seconds (as shown in the logs)

#### Optimized Build (optimized.Dockerfile)

- **Advantage**: Since `requirements.txt` remains unchanged, the layers for `COPY requirements.txt` and `pip install` are cached
- **Benefit**: No need to re-download dependencies, significantly faster rebuilds
- **Build Time**: ~0.9 seconds (as shown in the logs)

### Build Logs for Reference

```txt
# Unoptimized build
$ docker image build -f bad.Dockerfile -t random-number:bad .
[+] Building 6.3s (10/10) FINISHED
 => [internal] load build definition from bad.Dockerfile
 => [internal] load metadata for docker.io/library/python:3.10-alpine
 => [auth] library/python:pull token for registry-1.docker.io
 => [internal] load .dockerignore
 => [1/4] FROM docker.io/library/python:3.10-alpine@sha256:0733909561f552d8557618ee738b2a5cbf3fdd
 => [internal] load build context
 => CACHED [2/4] WORKDIR /app
 => [3/4] COPY . .
 => [4/4] RUN pip install -r requirements.txt
 => exporting to image
 => => writing image sha256:10fffc577e9cc601bfe9c3298911f313a6b519259ada49266cf19989bd6e0e02
 => => naming to docker.io/library/random-number:bad

# Optimized build
$ docker build -f optimized.Dockerfile -t random-number:opt .
[+] Building 0.9s (10/10) FINISHED
 => [internal] load build definition from optimized.Dockerfile
 => [internal] load metadata for docker.io/library/python:3.10-alpine
 => [internal] load .dockerignore
 => [1/5] FROM docker.io/library/python:3.10-alpine@sha256:0733909561f552d8557618ee738b2a5cbf3fdd
 => [internal] load build context
 => CACHED [2/5] WORKDIR /app
 => CACHED [3/5] COPY requirements.txt
 => CACHED [4/5] RUN pip install -r requirements.txt
 => [5/5] COPY main.py
 => exporting to image
 => => writing image sha256:752b5a6bf26b2d3c92a38422173fc4210e61e90c2dc5609c06980906fd48f181
 => => naming to docker.io/library/random-number:opt
```

> **Key Takeaway**: The optimized Dockerfile demonstrates how proper layer ordering and caching can significantly improve build times and reduce unnecessary network usage.
