## Overview
This builds a docker image of [minio](https://minio.io) based on their latest commit in their [github repo](https://github.com/minio/minio). Please review minio's docs for using the containers.

The dockerfile uses a multistage build to keep the final image smaller, while allowing the build process to be seperate `RUN` steps. This simplifies debugging errors in compiling the binary.

You can find my copy of the image at [liaden/minio-arm64](https://hub.docker.com/r/liaden/minio-arm64/). I have built this with the intent of using it on the Rock64 SBC.
