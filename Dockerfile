FROM amazonlinux:2023

# Install necessary dependencies
RUN yum update -y && \
    yum install -y jq wget && \
    wget https://github.com/mikefarah/yq/releases/download/v4.14.2/yq_linux_amd64 -O /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

# Set the entrypoint to bash for convenience
ENTRYPOINT ["/bin/bash"]
