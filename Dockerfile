#cloning 

FROM bitnami/git:latest as clone

RUN git clone https://projects.blender.org/blender/blender.git

# Use same image as when you built `bpy`
FROM python:3.10-bookworm as base
# Copy over files from the `blender` image
# COPY --from=blender /opt/blender/site-packages/ /path/to/site-packages/
COPY xvfb /etc/init.d/

RUN chmod +x /etc/init.d/xvfb && \
    useradd xvfb && \
    update-rc.d xvfb defaults && \
    echo "export DISPLAY=:0" >> ~/.bashrc

RUN apt-get update 

RUN apt-get install \
# `xvfb` dependencies
    xorg \
    subversion \
    openbox \
    xvfb \
# `blender` dependencies
    libxxf86vm1 \
    libxkbcommon-x11-0 \
    libxfixes3 \
    libgl1 \
    libpng-dev \
    libjpeg-dev \
    mesa-utils \
    # libc-dev-bin \
    linux-libc-dev \
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
    libegl-dev \
    libwayland-dev \
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
    libpng-dev \
    libjpeg-dev \
    mesa-utils \
    libc-dev-bin \
    linux-libc-dev -y

# RUN pip install bpy

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

FROM base

ENV WITH_LIBS_PRECOMPILED=OFF

COPY --from=clone blender ./blender

WORKDIR /blender

# RUN ./build_files/build_environment/install_linux_packages.py && \
#   make headless && \ 
#   make install

# ENV WITH_LIBS_PRECOMPILED=FALSE

RUN  make update
RUN ./build_files/build_environment/install_linux_packages.py --all
RUN  make deps
RUN  make headless 
RUN  make install

# RUN curl -L "https://builder.blender.org/download/daily/blender-3.6.7-stable+v36.cbd81f283d58-linux.x86_64-release.tar.xz" -o "blender.tar.xz" && \
#     tar -xvf blender.tar.xz --strip-components=1 -C /bin && \
#     rm -rf blender.tar.xz && \
#     rm -rf blender

# Set up the virtual display environment variable
ENV DISPLAY :99

# # Create a script to start Xvfb and then run the command
# RUN echo '#!/bin/bash\nXvfb :99 -screen 0 3840x2160x24 &\nexec "$@"' > /entrypoint.sh \
#     && chmod +x /entrypoint.sh

# ENTRYPOINT ["/entrypoint.sh"]
