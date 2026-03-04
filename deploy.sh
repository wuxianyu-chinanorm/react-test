#!/usr/bin/env bash
#
# Deploy script: git pull (ff-only), build image, stop old container, run new one.
# Intended for remote SSH use. Any failure exits 1 and reports the error.
#

set -euo pipefail

# Tag and container name: MMDDHHMM (4-digit date, 4-digit time)
DATETIME=$(date +%m%d%H%M)
IMAGE_TAG="react:${DATETIME}"
CONTAINER_NAME="react_${DATETIME}"

echo "Tag: ${IMAGE_TAG}  Container: ${CONTAINER_NAME}"

# 1. Git pull fast-forward only
echo ">>> git pull --ff-only"
if ! git pull --ff-only; then
  echo "ERROR: git pull --ff-only failed (cannot fast-forward or network/repo error)." >&2
  exit 1
fi

# 2. Docker build
echo ">>> docker build -t ${IMAGE_TAG} ."
if ! docker build -t "${IMAGE_TAG}" .; then
  echo "ERROR: docker build failed." >&2
  exit 1
fi

# 3. Stop container that is on port 8901 and has name starting with "react"
CONTAINER_ID=$(docker ps -q --filter "publish=8901" --filter "name=react" | head -1)
if [ -n "${CONTAINER_ID}" ]; then
  echo ">>> Stopping container ${CONTAINER_ID} (port 8901, name like react*)"
  if ! docker stop "${CONTAINER_ID}"; then
    echo "ERROR: docker stop failed." >&2
    exit 1
  fi
  docker rm "${CONTAINER_ID}" 2>/dev/null || true
fi

# 4. Run new container
echo ">>> docker run -p 8901:80 --name ${CONTAINER_NAME} -q -d ${IMAGE_TAG}"
if ! docker run -p 8901:80 --name "${CONTAINER_NAME}" -q -d "${IMAGE_TAG}"; then
  echo "ERROR: docker run failed." >&2
  exit 1
fi

echo "Done. Container ${CONTAINER_NAME} is running on port 8901."
