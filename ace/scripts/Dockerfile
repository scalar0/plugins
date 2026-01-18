# syntax=docker/dockerfile:1
# check=error=true

ARG UBUNTU_VERSION=latest

FROM ubuntu:${UBUNTU_VERSION}

ARG APE_GH_URL
ARG CLEX_GH_URL

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y software-properties-common

RUN add-apt-repository ppa:git-core/ppa && \
    apt-add-repository ppa:swi-prolog/devel && \
    apt-get update && apt-get install -y \
    git curl make unzip glibc-source graphviz swi-prolog openssh-client

RUN git clone --depth 1 $APE_GH_URL && cd APE && \
    curl -L $CLEX_GH_URL > prolog/lexicon/clex_lexicon.pl && \
    make build && make install && chmod +x /APE/ape.exe && \
    ln -sf /APE/ape.exe /usr/local/bin/ape && \
    ape -version

# Default to running the Ape CLI so the container can be used like a tool.
ENTRYPOINT ["/usr/local/bin/ape"]
CMD ["-help"]