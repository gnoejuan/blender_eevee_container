FROM bitnami/python:3.10.13

ARG BLENDER_VERSION

# Install dependencies for Xvfb and Blender
RUN install_packages \
    ca-certificates \
    sudo \
#    python3 \
    git \
    xvfb \
    libegl1 \
    build-essential \
    subversion \
    cmake \
    libx11-dev \
    libxxf86vm-dev \
    libxcursor-dev \
    libxi-dev \
    libxrandr-dev \
    libxinerama-dev \
    libegl-dev

RUN install_packages libwayland-dev \
    wayland-protocols \
    libxkbcommon-dev \
    libdbus-1-dev \
    linux-libc-dev

RUN git clone https://projects.blender.org/blender/blender.git

WORKDIR /blender

RUN ls -R
RUN ./$(find /blender -name "install_linux_packages.py") --all && \
  make && \ 
  make install

# Set up the virtual display environment variable
ENV DISPLAY :99

# Create a script to start Xvfb and then run the command
RUN echo '#!/bin/bash\nXvfb :99 -screen 0 1024x768x24 &\nexec "$@"' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
