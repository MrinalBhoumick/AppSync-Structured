# Use Amazon Linux 2023 as the base image
FROM amazonlinux:2023

# Install necessary packages
RUN yum update -y && \
    yum install -y jq wget unzip && \
    yum clean all

# Install yq
RUN wget https://github.com/mikefarah/yq/releases/download/v4.14.2/yq_linux_amd64 -O /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Set the working directory
WORKDIR /build

# Copy the buildspec.yml and scripts into the container
COPY buildspec.yml /buildspec.yml
COPY scripts/ /build/scripts/

# Make sure all scripts are executable
RUN chmod +x /build/scripts/*.sh

# Define the entrypoint
ENTRYPOINT ["/bin/bash", "-c"]
