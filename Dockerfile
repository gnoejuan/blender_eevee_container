# answer from stack exchange

# Use debian:buster-slim because it's small enough and runs faster than alpine
FROM debian:buster-slim as blender

WORKDIR /opt/blender

RUN export DEBIAN_FRONTEND=noninteractive && \
# Enables some additional packages that are needed for Blender to work in debian:buster-slim
    echo 'deb http://deb.debian.org/debian testing main contrib non-free' > /etc/apt/sources.list.d/testing.list && \
    apt update && \
    apt install -yq --no-install-recommends \
        build-essential \
        apt-transport-https \
        ca-certificates \
        git \
        subversion \
        cmake \
        python3 \
        libx11-dev \
        libxxf86vm-dev \
        libxcursor-dev \
        libxi-dev \
        libxrandr-dev \
        libxinerama-dev \
        libglew-dev && \
# Git complains that it can't clone blender if you don't run this
    update-ca-certificates && \
    git clone https://git.blender.org/blender.git blender && \
# Check out linux dependency
    mkdir lib && \
    cd lib && \
    svn checkout https://svn.blender.org/svnroot/bf-blender/trunk/lib/linux_centos7_x86_64 && \
    cd ../blender && \
# Get more dependencies
    make update && \
# Build bpy
    make bpy && \
    cd ../build_linux_bpy && \
# Change install path
    cmake ../blender \
        -DWITH_INSTALL_PORTABLE=ON \
        -DCMAKE_INSTALL_PREFIX=/opt/blender/site-packages && \
# Install finished module to /opt/blender/site-packages
    make install && \
# Do some cleanup because why the hell not
    apt autoremove -yq && \
    apt clean && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    rm -rf /opt/blender/{blender,lib,build_linux_bpy}

# Use same image as when you built `bpy`
FROM debian:buster-slim
# Copy over files from the `blender` image
COPY --from=blender /opt/blender/site-packages/ /path/to/site-packages/
COPY xvfb /etc/init.d/

RUN chmod +x /etc/init.d/xvfb && \
    useradd xvfb && \
    update-rc.d xvfb defaults && \
    echo "export DISPLAY=:0" >> ~/.bashrc

RUN apt install -yq \
# `xvfb` dependencies
    xorg \
    openbox \
    xvfb \
# `blender` dependencies
    libxxf86vm1 \
    libxfixes3 \
    libgl1 \
    libpng-dev \
    libjpeg-dev \
    mesa-utils \
    libc-dev-bin \
    linux-libc-dev -y

# FROM python:3.10-bookworm

# # Install dependencies for Xvfb and Blender
# RUN apt-get update
# RUN apt-get install \
#     ca-certificates \
#     sudo \
#     python3 \
#     git \
#     xvfb \
#     libegl1 \
#     build-essential \
#     subversion \
#     cmake \
#     libx11-dev \
#     libxxf86vm-dev \
#     libxcursor-dev \
#     libxi-dev \
#     libxrandr-dev \
#     libxinerama-dev \
#     gcc \
#     g++ \
#     libglew-dev \
#     libegl-dev -y

# RUN apt-get install libwayland-dev \
#     wayland-protocols \
#     libxkbcommon-dev \
#     libdbus-1-dev \
#     autoconf \
#     automake \
#     bison \
#     libtool \
#     yasm \
#     tcl \
#     ninja-build \
#     meson \
#     python3-mako \
#     patchelf \
#     libasound2-dev \
#     pulseaudio \
#     ffmpeg \
#     libpng-dev \
#     libjpeg-dev \
#     mesa-utils \
#     libc-dev-bin \
#     linux-libc-dev -y

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

# RUN curl -L "https://builder.blender.org/download/daily/blender-3.6.7-stable+v36.cbd81f283d58-linux.x86_64-release.tar.xz" -o "blender.tar.xz" && \
#     tar -xvf blender.tar.xz --strip-components=1 -C /bin && \
#     rm -rf blender.tar.xz && \
#     rm -rf blender

# # Set up the virtual display environment variable
# ENV DISPLAY :99

# # Create a script to start Xvfb and then run the command
# RUN echo '#!/bin/bash\nXvfb :99 -screen 0 3840x2160x24 &\nexec "$@"' > /entrypoint.sh \
#     && chmod +x /entrypoint.sh

# ENTRYPOINT ["/entrypoint.sh"]
