FROM bitnami/minideb:latest

ARG BLENDER_VERSION

# Install dependencies for Xvfb and Blender
RUN apt-get update && apt-get install -y \
    xvfb \
    libegl1 \
    && rm -rf /var/lib/apt/lists/*
ENV TITLE=Blender

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    ocl-icd-libopencl1 \
    xz-utils && \
  ln -s libOpenCL.so.1 /usr/lib/x86_64-linux-gnu/libOpenCL.so && \
  echo "**** install blender ****" && \
  mkdir /blender && \
  if [ -z ${BLENDER_VERSION+x} ]; then \
    BLENDER_VERSION=$(curl -sL https://mirrors.ocf.berkeley.edu/blender/source/ \
      | awk -F'"|/"' '/blender-[0-9]*\.[0-9]*\.[0-9]*\.tar\.xz/ && !/md5sum/ {print $4}' \
      | tail -1 \
      | sed 's|blender-||' \
      | sed 's|\.tar\.xz||'); \
  fi && \
  BLENDER_FOLDER=$(echo "Blender${BLENDER_VERSION}" | sed -r 's|(Blender[0-9]*\.[0-9]*)\.[0-9]*|\1|') && \
  curl -o \
    /tmp/blender.tar.xz -L \
    "https://mirrors.ocf.berkeley.edu/blender/release/${BLENDER_FOLDER}/blender-${BLENDER_VERSION}-linux-x64.tar.xz" && \
  tar xf \
    /tmp/blender.tar.xz -C \
    /blender/ --strip-components=1 && \
  ln -s \
    /blender/blender \
    /usr/bin/blender && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY /root /

# Set up the virtual display environment variable
ENV DISPLAY :99

# Create a script to start Xvfb and then run the command
RUN echo '#!/bin/bash\nXvfb :99 -screen 0 1024x768x24 &\nexec "$@"' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
