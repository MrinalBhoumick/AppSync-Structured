FROM alpine:latest

RUN yum update -y && \
    yum install -y jq wget unzip && \
    yum clean all

RUN wget https://github.com/mikefarah/yq/releases/download/v4.14.2/yq_linux_amd64 -O /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

# Set the working directory
WORKDIR /build

# Copy the buildspec.yml and scripts into the container
COPY buildspec.yml /buildspec.yml
COPY scripts/ /build/scripts/

# Make sure all scripts are executable
RUN chmod +x /build/scripts/*.sh

# Define the entrypoint
ENTRYPOINT ["/bin/bash", "-c"]
