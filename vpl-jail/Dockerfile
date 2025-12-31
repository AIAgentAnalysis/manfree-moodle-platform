# VPL Jail Server Dockerfile
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    git \
    build-essential \
    openjdk-11-jdk \
    python3 \
    python3-pip \
    gcc \
    g++ \
    make \
    sudo \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Download VPL Jail System v2.5 (latest stable release)
WORKDIR /
RUN git clone --branch v2.5 --depth 1 https://github.com/jcrodriguez-dis/vpl-jail-system.git /vpl-jail-system

WORKDIR /vpl-jail-system

# Install VPL Jail System v2.5
RUN chmod +x install-sh install-vpl-sh \
    && ./install-vpl-sh

# Configure VPL Jail for Docker - disable firewall
RUN sed -i 's/^FIREWALL=.*/FIREWALL=0/' /etc/vpl/vpl-jail-system.conf

# Create jail directory and required structure
RUN mkdir -p /jail/etc && \
    cp /etc/passwd /jail/etc/passwd && \
    cp /etc/group /jail/etc/group && \
    cp /etc/shadow /jail/etc/shadow && \
    chmod 644 /jail/etc/passwd /jail/etc/group && \
    chmod 640 /jail/etc/shadow

# Cleanup
WORKDIR /
RUN rm -rf /vpl-jail-system

# Copy startup script
COPY start-vpl.sh /start-vpl.sh
RUN chmod +x /start-vpl.sh

# Expose ports
EXPOSE 80 443

# Start VPL jail server
CMD ["/start-vpl.sh"]
