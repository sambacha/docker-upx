#!/bin/bash
DOCKER_BUILDKIT=1 docker buildx build $VERSION_DIR -t manifoldfinance/$VERSION_DIR-upx:latest
