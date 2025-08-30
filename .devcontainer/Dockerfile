FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y openjdk-11-jdk wget curl tar ssh lsof net-tools procps && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/hadoop /home/vscode/hadoopdata /workspace \
    && chown -R vscode:vscode /home/vscode/hadoopdata /workspace

USER vscode
WORKDIR /workspace
