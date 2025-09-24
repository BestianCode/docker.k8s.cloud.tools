FROM debian:bookworm-slim

ARG TARGETARCH

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y \
       curl wget \
       jq \
       gpg \
       unzip openssh-client ca-certificates libssl3

# AWS CLI
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
      curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"; \
    fi
RUN unzip -oqq awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws \
    && aws --version

# GCP CLI
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin

# Azure CLI
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/microsoft.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ bookworm main" > /etc/apt/sources.list.d/azure-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends azure-cli \
    && az version

# Kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${TARGETARCH}/kubectl" \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${TARGETARCH}/kubectl.sha256" \
    && echo "$(cat kubectl.sha256) kubectl" | sha256sum --check \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm -f kubectl kubectl.sha256 \
    && kubectl version --client

# Docker
RUN install -m 0755 -d /etc/apt/keyrings \
    && (curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg) \
    && chmod a+r /etc/apt/keyrings/docker.gpg

RUN echo \
      "deb [arch=$TARGETARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update \
    && apt-get install -y --no-install-recommends --allow-unauthenticated docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    && docker --version

# Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    rm -f get_helm.sh && \
    helm version

# TZ
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archives/*
