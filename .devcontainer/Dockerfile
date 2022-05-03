FROM ubuntu:focal

USER root

RUN set -o xtrace \
    && cd /opt \
    && apt-get update \
    && apt-get install -y openjdk-11-jdk \
    && apt-get install -y sudo wget zip chromium-browser unzip git clang-format openssh-client curl --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

ENV FLUTTER_HOME=${HOME}/sdks/flutter \
    FLUTTER_VERSION=$flutter_version
ENV FLUTTER_ROOT=$FLUTTER_HOME
ENV PATH ${PATH}:${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:/root/.pub-cache/bin

ARG flutter_version
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME}

RUN flutter config --enable-web \
    && flutter doctor \
    && chown -R root:root ${FLUTTER_HOME}

RUN flutter pub global activate melos
RUN flutter pub global activate spec_cli
RUN flutter pub global activate flutterfire_cli
RUN flutter pub global activate flutter_plugin_tools
