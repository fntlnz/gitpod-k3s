FROM gitpod/workspace-full

USER root

WORKDIR /gitpod
COPY .gitpod .gitpod
RUN .gitpod/install.sh

