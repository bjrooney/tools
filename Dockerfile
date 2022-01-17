# docker build -t doctl_local --build-arg DOCTL_VERSION=1.23.1 .
#
# This Dockerfile exists so casual uses of `docker build` and `docker run` do something sane.
# We don't recommend using it: If you want to develop in docker, please use `make docker_build`
# instead.

FROM alpine:latest 

ENV DISPLAY :1
# alternative 1024x768x16
ENV RESOLUTION 1920x1080x24

ENV PATH=${PATH}:/root/.krew/bin:/root/.arkade/bin:/root/.linkerd2/bin
RUN apk add --update --no-cache \
            python3 \
            py3-pip \
            curl \
            git \
            ncurses \
            openssl \
            tree \
            vim \
            jq \
            wget \
            bash \
            util-linux \
            nodejs \
            npm \
            sed \
            firefox \
            x11vnc \
            xvfb \
            ttf-dejavu \
            xfce4 \
            faenza-icon-theme \
            gnome-terminal



# setup novnc (requires bash)
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
  bash \
  novnc && \
  ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

RUN        pip3 install --upgrade     pip \
            && pip3 install --no-cache-dir boto3 \
            && pip3 install --no-cache-dir awscli \
            && npm install -g aws-azure-login \
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
RUN krew install popeye 

RUN curl -L https://github.com/gimlet-io/gimlet-cli/releases/download/v0.3.0/gimlet-$(uname)-$(uname -m) -o gimlet \
&& chmod +x gimlet \
&& mv ./gimlet /usr/local/bin/gimlet \
&& gimlet --version

RUN git clone https://github.com/andrey-pohilko/registry-cli.git \
&& pip3 install -r registry-cli/requirements-build.txt \
&& python3 /root/registry-cli/registry.py || :
 
RUN rm -rf /tmp/*
RUN mkdir ~/.vnc
RUN x11vnc -storepasswd 1234 ~/.vnc/passwd
# setup supervisor
COPY supervisor /tmp
SHELL ["/bin/bash", "-c"]
RUN apk add --no-cache supervisor && \
  echo_supervisord_conf > /etc/supervisord.conf && \
  sed -i -r -f /tmp/supervisor.sed /etc/supervisord.conf && \
  mkdir -pv /etc/supervisor/conf.d /var/log/{novnc,x11vnc,xfce4,xvfb} && \
  mv /tmp/supervisor-*.ini /etc/supervisor/conf.d/ && \
  rm -fr /tmp/supervisor*

CMD ["supervisord", "-c", "/etc/supervisord.conf", "-n"]