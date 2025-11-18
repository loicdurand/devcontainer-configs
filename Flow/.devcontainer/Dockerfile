# .devcontainer/Dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Node 20 via nvm
ENV NODE_VERSION=20
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && . /root/.nvm/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin:${PATH}"

# Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Expo + EAS + Supabase CLI global
RUN npm install -g expo-cli eas-cli supabase

EXPOSE 11434 19000 19001 19002