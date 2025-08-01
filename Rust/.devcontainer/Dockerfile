FROM rust:1.82-slim-bookworm

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    sudo \
    git \
    default-mysql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create directories for Rust project
RUN mkdir -p /workspace

# Create non-root user
ARG USERNAME=loic
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && usermod -aG sudo $USERNAME

# Add aliases to .bashrc
SHELL ["/bin/bash", "-c"]
RUN echo "alias ll='ls -alF'" >> /home/$USERNAME/.bashrc \
    && echo "alias la='ls -A'" >> /home/$USERNAME/.bashrc \
    && echo "alias l='ls -CF'" >> /home/$USERNAME/.bashrc \
    && echo "alias ..='cd ..'" >> /home/$USERNAME/.bashrc \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME \
    && cp /home/$USERNAME/.bashrc /root/ \
    && chown root:root /root/.bashrc \
    && chmod 644 /root/.bashrc \
    && source /home/$USERNAME/.bashrc

# Set working directory
WORKDIR /workspace

# Set permissions
RUN chown -R $USERNAME:$USERNAME /workspace
RUN chmod -R 775 /workspace

# Expose port for Rust application (optional, adjust as needed)
EXPOSE 8080