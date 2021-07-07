FROM ubuntu:20.04

LABEL maintainer="Amir Fakour"

ENV TZ=Asia/Tehran

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update -y

RUN apt-get install -y \
    git \
    vim \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker’s official GPG key
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the Docker's stable repository
RUN echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
RUN apt-get update -y \
    && apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker-compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Install gitlab-runners
RUN curl -L --output /usr/local/bin/gitlab-runner "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64" \
    && chmod +x /usr/local/bin/gitlab-runner \
    && useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash \
    && gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner \
    && gitlab-runner start

CMD gitlab-runner run