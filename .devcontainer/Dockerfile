# Dev container Dockerfile for Delivery app
FROM mcr.microsoft.com/devcontainers/base:ubuntu

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl git unzip xz-utils zip libglu1-mesa openjdk-17-jdk ca-certificates procps && \
    rm -rf /var/lib/apt/lists/*

# Install Node via Nodesource (backup in case features not applied)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK (stable)
ENV FLUTTER_HOME=/usr/local/flutter
RUN git clone https://github.com/flutter/flutter.git -b stable ${FLUTTER_HOME} --depth 1 && \
    ${FLUTTER_HOME}/bin/flutter config --no-analytics || true

# Add flutter to PATH
ENV PATH="${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Create a scripts folder for devcontainer hooks
RUN mkdir -p /workspaces/.devcontainer-scripts && chmod -R a+rx /workspaces/.devcontainer-scripts

CMD ["/bin/bash"]
