#!/bin/bash
TAG="${TRAVIS_BUILD_NUMBER}-${TRAVIS_COMMIT}"

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

echo "*****************"
docker images

# Build a new image and use the "latest" image as a cache
docker build . \
  --target web \
  --cache-from "thedxw/beis-report-official-development-assistance:${TAG}-test" \
  -t "thedxw/beis-report-official-development-assistance:${TAG}"

docker push "${DOCKER_IMAGE}"
