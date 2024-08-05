FROM alpine:latest

# Install dependencies
RUN apk update && apk add --no-cache \
    bash \
    curl \
    jq

# Install yq
RUN wget https://github.com/mikefarah/yq/releases/download/v4.14.2/yq_linux_amd64 -O /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq

# Verify installations
RUN jq --version && yq --version

# Set bash as the default shell
CMD ["/bin/bash"]
