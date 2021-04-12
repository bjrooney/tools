# docker build -t doctl_local --build-arg DOCTL_VERSION=1.23.1 .
#
# This Dockerfile exists so casual uses of `docker build` and `docker run` do something sane.
# We don't recommend using it: If you want to develop in docker, please use `make docker_build`
# instead.

FROM alpine:latest 

ENV PATH=${PATH}:/root/.krew/bin:/root/.arkade/bin:/root/.linkerd2/bin

RUN apk add --no-cache \
            python3 \
            py3-pip \
            curl \
            git \
            ncurses \
            # openssl \
            # tree \
            # vim \
            # jq \
            wget \
            bash \
            util-linux \
            && pip3 install --upgrade pip \
            # && pip3 install \
            # awscli \
            && rm -rf /var/cache/apk/* 

RUN bash

WORKDIR /root


RUN curl -sLS https://dl.get-arkade.dev | sh
RUN arkade --help
RUN ark --help  # a handy alias

RUN ark get helm
RUN helm plugin install --version master https://github.com/sonatype-nexus-community/helm-nexus-push.git
RUN helm nexus-push --help

RUN ark get kubectl
RUN ark get kubectx
RUN ark get doctl
RUN ark get krew
RUN ark get linkerd2
RUN krew install ns
RUN krew install ctx
RUN krew install cert-manager
RUN krew install popeye
RUN krew install starboard
RUN krew install view-utilization
RUN krew install bd-xray
RUN krew install status
RUN krew install topology
RUN krew install janitor
RUN krew install graph
RUN krew install flame

RUN curl -L https://github.com/gimlet-io/gimlet-cli/releases/download/v0.3.0/gimlet-$(uname)-$(uname -m) -o gimlet
RUN chmod +x gimlet
RUN mv ./gimlet /usr/local/bin/gimlet
RUN gimlet --version

RUN git clone https://github.com/andrey-pohilko/registry-cli.git
RUN pip3 install -r registry-cli/requirements-build.txt

RUN python3 /root/registry-cli/registry.py || :
 
RUN rm -rf /tmp/*
CMD ["sleep", "infinity"]