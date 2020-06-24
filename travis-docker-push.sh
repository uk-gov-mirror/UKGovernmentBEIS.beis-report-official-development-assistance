#!/bin/bash
TAG="${TRAVIS_BUILD_NUMBER}-${TRAVIS_COMMIT}"
DOCKER_BUILDKIT="1"

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# Build a new image and use the "latest" image as a cache
docker build . \
  --target web \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --cache-from "thedxw/beis-report-official-development-assistance:latest" \
  --progress=plain \
  -t "thedxw/beis-report-official-development-assistance:${TAG}"

# Update this image to be the new latest for future cache use
docker tag "thedxw/beis-report-official-development-assistance:${TAG}" \
  "thedxw/beis-report-official-development-assistance:latest"

docker push "${DOCKER_IMAGE}"
