FROM ubuntu:23.04

ENV DEBIAN_FRONTEND noninteractive

ENV DANGER_HOME       /opt/danger
ENV ANDROID_HOME      /opt/android-sdk-linux
ENV ANDROID_SDK_HOME  ${ANDROID_HOME}
ENV ANDROID_SDK_ROOT  ${ANDROID_HOME}
ENV ANDROID_SDK       ${ANDROID_HOME}

ENV PATH "${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/cmdline-tools/tools/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/tools/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/build-tools/30.0.3"
ENV PATH "${PATH}:${ANDROID_HOME}/platform-tools"
ENV PATH "${PATH}:${ANDROID_HOME}/emulator"
ENV PATH "${PATH}:${ANDROID_HOME}/bin"

RUN dpkg --add-architecture i386 && \
    apt-get update -yqq && \
    apt-get install -y sudo openjdk-17-jdk curl expect git git-lfs libc6:i386 libgcc1:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386 openjdk-11-jdk wget unzip vim npm yarn make ca-certificates zip nodejs && \
    apt-get clean

RUN sudo update-java-alternatives --set java-1.17.0-openjdk-amd64

RUN npm install -g danger

RUN curl -o kotlin-compiler.zip -L https://github.com/JetBrains/kotlin/releases/download/v1.7.0/kotlin-compiler-1.7.0.zip && \
    unzip -d ${DANGER_HOME} kotlin-compiler.zip && \
    rm -rf kotlin-compiler.zip
ENV PATH "$PATH:${DANGER_HOME}/kotlinc/bin"

RUN curl -s https://raw.githubusercontent.com/danger/kotlin/master/scripts/install.sh | bash
RUN danger-kotlin

RUN groupadd android && useradd -d /opt/android-sdk-linux -g android android

COPY tools /opt/tools
COPY licenses /opt/licenses

WORKDIR /opt/android-sdk-linux

RUN /opt/tools/entrypoint.sh built-in

RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "tools"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "cmdline-tools;latest"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "build-tools;30.0.3"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "platform-tools"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "platforms;android-33"
RUN /opt/android-sdk-linux/cmdline-tools/tools/bin/sdkmanager "system-images;android-33;google_apis;x86_64"

CMD /opt/tools/entrypoint.sh built-in
