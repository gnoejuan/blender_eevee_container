FROM python:3.10-bookworm

# Install dependencies for Xvfb and Blender
RUN apt-get update
RUN apt-get install \
    ca-certificates \
    sudo \
    python3 \
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
    gcc \
    g++ \
    libglew-dev \
    libegl-dev -y

RUN apt-get install libwayland-dev \
    wayland-protocols \
    libxkbcommon-dev \
    libdbus-1-dev \
    autoconf \
    automake \
    bison \
    libtool \
    yasm \
    tcl \
    ninja-build \
    meson \
    python3-mako \
    patchelf \
    libasound2-dev \
    pulseaudio \
    ffmpeg \
    linux-libc-dev -y

# RUN git clone https://projects.blender.org/blender/blender.git

# WORKDIR /blender

# RUN ./build_files/build_environment/install_linux_packages.py && \
#   make headless && \ 
#   make install

# RUN ./build_files/build_environment/install_linux_packages.py --all

# RUN  make update

# RUN  make deps
# RUN  make headless 
# RUN  make install

RUN curl -L "https://www.blender.org/download/release/Blender3.6/blender-3.6.7-linux-x64.tar.xz" -o "blender.tar.xz" && \
    tar -xvf blender.tar.xz --strip-components=1 -C /bin && \
    rm -rf blender.tar.xz && \
    rm -rf blender

# Set up the virtual display environment variable
ENV DISPLAY :99

# Create a script to start Xvfb and then run the command
RUN echo '#!/bin/bash\nXvfb :99 -screen 0 3840x2160x32 &\nexec "$@"' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
