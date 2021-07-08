FROM gitpod/workspace-full

USER root

COPY .gitpod /tmp/.gitpod
RUN /tmp/.gitpod/install.sh
RUN /tmp/.gitpod/prepare-rootfs.sh 