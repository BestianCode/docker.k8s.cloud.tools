# Docker Image for Kubernetes Pipelines

This Docker image is designed to support delivery pipelines for Kubernetes, whether they're on-premises or in the AWS/GCP cloud.

## Features

- **Update Frequency**: Weekly.
- **Operating System**: Debian Bookworm (12) Slim.
- **Timezone**: Europe/Berlin.

## Pre-installed Tools

The image comes with a set of pre-installed tools commonly used in Kubernetes pipelines:

- `curl` and `wget`
- `jq`
- `docker`
- `kubectl`
- `helm`
- `AWS CLI`
- `GCP CLI + gke-gcloud-auth-plugin`

## Usage

You can use this image as a base image in your Dockerfiles or in your CI/CD pipelines to deploy applications to Kubernetes.

## URLs

- **GitHub**: https://github.com/BestianCode/docker_k8s.cloud.tools
- **DockerHub**: https://hub.docker.com/r/bestian/k8s.cloud.tools
