#!/bin/bash -e

set -e

[[ "${AWS_VERSION}" ]] || (echo "ERROR: AWS_VERSION variable not set." && exit 1)
[[ "${KUBECTL_VERSION}" ]] || (echo "ERROR: KUBECTL_VERSION variable not set." && exit 1)
[[ "${HELM_VERSION}" ]] || (echo "ERROR: HELM_VERSION variable not set." && exit 1)
[[ "${TERRAFORM_VERSION}" ]] || (echo "ERROR: TERRAFORM_VERSION variable not set." && exit 1)
[[ "${CONTAINER_REGISTRY_PATH}" ]] || (echo "ERROR: CONTAINER_REGISTRY_PATH variable not set." && exit 1)

[[ "${CONTAINER_REGISTRY_USERNAME}" ]] &&
[[ "${CONTAINER_REGISTRY_PASSWORD}" ]] &&
echo "${CONTAINER_REGISTRY_PASSWORD}" | \
docker login "${CONTAINER_REGISTRY_PATH}" \
--username "${CONTAINER_REGISTRY_USERNAME}" \
--password-stdin

export CONTAINER_TAG="${AWS_VERSION}-kubectl-${KUBECTL_VERSION}-helm-${HELM_VERSION}-terraform-${TERRAFORM_VERSION}"
docker build . \
--build-arg AWS_VERSION \
--build-arg KUBECTL_VERSION \
--build-arg HELM_VERSION \
--build-arg TERRAFORM_VERSION \
--file Dockerfile \
--tag "${CONTAINER_REGISTRY_PATH}:${CONTAINER_TAG}"

[[ "${CONTAINER_REGISTRY_PUSH}" -eq 1 ]] &&
docker push "${CONTAINER_REGISTRY_PATH}:${CONTAINER_TAG}"
