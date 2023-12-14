FROM python:3.12.1

ARG BLENDER_VERSION

# Install dependencies for Xvfb and Blender
RUN apt-get update
RUN apt-get install \
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
    libegl-dev -y

RUN apt-get install libwayland-dev \
    wayland-protocols \
    libxkbcommon-dev \
    libdbus-1-dev \
    linux-libc-dev -y

RUN git clone https://projects.blender.org/blender/blender.git

RUN pwd

WORKDIR /blender

# RUN ./build_files/build_environment/install_linux_packages.py && \
#   make headless && \ 
#   make install

RUN ./build_files/build_environment/install_linux_packages.py && \
  make release && \ 
  make install

# Set up the virtual display environment variable
ENV DISPLAY :99

# Create a script to start Xvfb and then run the command
RUN echo '#!/bin/bash\nXvfb :99 -screen 0 1024x768x24 &\nexec "$@"' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
