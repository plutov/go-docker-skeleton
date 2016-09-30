# Go skeleton build environment

This Docker based build environment can be used to start all your Go apps. I am personally use it to save my time with init steps.

## Build

 - `make` - compiles the app. This will use a Docker image to build your app, with the current directory volume-mounted into place.  This will store incremental state for the fastest possible build.
 - `make container` - builds the container image.  It will calculate the image tag based on the most recent git tag, and whether the repo is "dirty" since that tag (see `make version`).
 - `make push` - pushes the container image to the `REGISTRY`.
 - `make clean` - clean up.

## Variables

Makefile:
   - `BIN` - your binary name
   - `PKG` - your package path
   - `REGISTRY` - the Docker registry you want to use

Dockerfile:
   - `MAINTAINER` - NAME <EMAIL>
