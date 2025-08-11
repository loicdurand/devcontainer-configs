FROM rust:1.82-slim-bookworm

# Update package sources to include contrib and non-free
# RUN echo "deb http://deb.debian.org/debian bookworm main contrib non-free" > /etc/apt/sources.list && \
#     echo "deb http://deb.debian.org/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
#     echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free" >> /etc/apt/sources.list

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    sudo \
    git \
    unzip \
    default-mysql-client \
    # Dépendances pour Tauri
    libwebkit2gtk-4.1-dev \
    build-essential \
    curl \
    wget \
    file \
    libxdo-dev \
    libssl-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev \
    libclang-dev \
    clang \
    # Dépendances pour Android
    openjdk-17-jdk \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Installing Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install -g npm@latest \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV LIBCLANG_PATH=/usr/lib/x86_64-linux-gnu
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

RUN mkdir -p /opt/android/cmdline-tools/latest
RUN cd /opt/android/cmdline-tools/latest && wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip
RUN cd /opt/android/cmdline-tools/latest && unzip cmdline-tools.zip
RUN rm /opt/android/cmdline-tools/latest/cmdline-tools.zip
RUN mv /opt/android/cmdline-tools/latest/cmdline-tools/* /opt/android/cmdline-tools/latest/
RUN rmdir /opt/android/cmdline-tools/latest/cmdline-tools/

ENV ANDROID_HOME=/opt/android
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin

# Accept Android SDK licenses
RUN yes | /opt/android/cmdline-tools/latest/bin/sdkmanager --licenses

# Install Android SDK and NDK components
RUN /opt/android/cmdline-tools/latest/bin/sdkmanager \
    "platforms;android-33" \
    "platform-tools" \
    "ndk;26.1.10909125" \
    "build-tools;33.0.0"

# Install Rust targets for Android
RUN rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android

# Install Tauri CLI
RUN cargo install create-tauri-app --locked
RUN cargo install cargo-watch

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

# Add aliases and environment variables to .bashrc
SHELL ["/bin/bash", "-c"]
RUN echo "alias ll='ls -alF'" >> /home/$USERNAME/.bashrc \
    && echo "alias la='ls -A'" >> /home/$USERNAME/.bashrc \
    && echo "alias l='ls -CF'" >> /home/$USERNAME/.bashrc \
    && echo "alias ..='cd ..'" >> /home/$USERNAME/.bashrc \
    && echo "export JAVA_HOME=$JAVA_HOME" >> /home/$USERNAME/.bashrc \
    && echo "export ANDROID_HOME=$ANDROID_HOME" >> /home/$USERNAME/.bashrc \
    && echo "export NDK_HOME=$NDK_HOME" >> /home/$USERNAME/.bashrc \
    && echo "export PATH=$PATH" >> /home/$USERNAME/.bashrc \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME \
    && cp /home/$USERNAME/.bashrc /root/ \
    && chown root:root /root/.bashrc \
    && chmod 644 /root/.bashrc \
    && source /home/$USERNAME/.bashrc

# Set working directory
WORKDIR /workspace

# Set permissions
RUN chown -R $USERNAME:$USERNAME /workspace
RUN chown -R $USERNAME:$USERNAME /usr/local/cargo
RUN chmod -R 775 /workspace

# Expose port for Rust/Tauri application
EXPOSE 8080

# CMD ["/bin/bash"]