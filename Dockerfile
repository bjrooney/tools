# docker build -t doctl_local --build-arg DOCTL_VERSION=1.23.1 .
#
# This Dockerfile exists so casual uses of `docker build` and `docker run` do something sane.
# We don't recommend using it: If you want to develop in docker, please use `make docker_build`
# instead.

FROM alpine:3.11

ENV DISPLAY :1
# alternative 1024x768x16
ENV RESOLUTION 1920x1080x24

ENV PATH=${PATH}:/root/.krew/bin:/root/.arkade/bin:/root/.linkerd2/bin
RUN apk add --update --no-cache \
            supervisor \
            chromium \
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
            sed \
            x11vnc \
            xvfb \
            ttf-dejavu \
            xfce4 \
            faenza-icon-theme \
            gnome-terminal \
            xterm \
            bash \
            zsh \
            desktop-file-utils \
            adwaita-icon-theme \
            ttf-dejavu \
            ffmpeg-libs \
            --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
            --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
            --upgrade nodejs npm  python3 py3-pip 

RUN         pip3 install --no-cache-dir awscli 
RUN         mkdir -p /usr/lib/node_modules/aws-azure-login/node_modules/puppeteer/.local-chromium \
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
 
RUN adduser -D -s /bin/bash -h /home/vncuser vncuser

# setup supervisor
COPY supervisor /tmp
SHELL ["/bin/bash", "-c"]
RUN echo_supervisord_conf > /etc/supervisord.conf && \
  sed -i -r -f /tmp/supervisor.sed /etc/supervisord.conf && \
  mkdir -pv /etc/supervisor/conf.d /var/log/{novnc,x11vnc,xfce4,xvfb} && \
  mv /tmp/supervisor-*.ini /etc/supervisor/conf.d/ && \
  rm -fr /tmp/supervisor*
RUN chmod -Rf 777 /etc/supervisor/conf.d/ 
RUN chmod 777 /etc/supervisord.conf
RUN chmod -Rf 777 /var/log
USER vncuser
WORKDIR /home/vncuser

CMD ["supervisord", "-c", "/etc/supervisord.conf", "-n"]