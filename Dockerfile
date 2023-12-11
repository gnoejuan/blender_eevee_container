FROM bitnami/minideb:latest

# Install dependencies for Xvfb and Blender
RUN apt-get update && apt-get install -y \
    xvfb \
    blender \
    libegl1 \
    && rm -rf /var/lib/apt/lists/*

# Set up the virtual display environment variable
ENV DISPLAY :99

# Create a script to start Xvfb and then run the command
RUN echo '#!/bin/bash\nXvfb :99 -screen 0 1024x768x24 &\nexec "$@"' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
