# docker build -t doctl_local --build-arg DOCTL_VERSION=1.23.1 .
#
# This Dockerfile exists so casual uses of `docker build` and `docker run` do something sane.
# We don't recommend using it: If you want to develop in docker, please use `make docker_build`
# instead.

FROM alpine:latest

ENV DISPLAY :1
# alternative 1024x768x16
ENV RESOLUTION 1920x1080x24

ENV PATH=${PATH}:/root/.krew/bin:/root/.arkade/bin:/root/.linkerd2/bin:/root/.nvm
RUN touch /root/.bashrc
RUN touch /root/.bash_profile
RUN touch /root/.zshrc
RUN touch /root/.profile

WORKDIR /root
RUN apk add --update --no-cache \
            supervisor \
            busybox-extras \
            firefox\
            python3 \
            py3-pip \
            ncurses \
            openssl \
            tree \
            vim \
            jq \
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
            curl \
            nodejs \
            npm \
            gcc
SHELL       ["/bin/bash", "-c"]

RUN brew install wget

RUN         pip3 install --no-cache-dir awscli 
# RUN         mkdir -p /usr/lib/node_modules/aws-azure-login/node_modules/puppeteer/.local-chromium 

# RUN        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
#            && nvm install --lts
RUN        npm install -g aws-azure-login
RUN        rm -rf /var/cache/apk/* 

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
RUN krew install kc

RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-415.0.0-linux-x86_64.tar.gz \
&& tar zxvf google-cloud-cli-415.0.0-linux-x86_64.tar.gz \
&& cd google-cloud-sdk \
&& chmod +x install.sh \
&& /bin/sh install.sh -q \
&& cd - \
&& rm -rf google-cloud* google-cloud-sdk

RUN curl -L https://github.com/cli/cli/releases/download/v2.22.0/gh_2.22.0_linux_amd64.tar.gz -o gh.tar.gz \
&& tar zxvf gh.tar.gz \
&& cd gh_2.22.0_linux_amd64/bin \
&& chmod +x gh \
&& mv ./gh /usr/local/bin/ \
&& gh --version \
&& cd - \
&& rm -rf gh *

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

RUN echo_supervisord_conf > /etc/supervisord.conf && \
  sed -i -r -f /tmp/supervisor.sed /etc/supervisord.conf && \
  mkdir -pv /etc/supervisor/conf.d /var/log/{novnc,x11vnc,xfce4,xvfb} && \
  mv /tmp/supervisor-*.ini /etc/supervisor/conf.d/ && \
  rm -fr /tmp/supervisor*
RUN chmod -Rf 777 /etc/supervisor/conf.d/ 
RUN chmod 777 /etc/supervisord.conf
RUN chmod -Rf 777 /var/log
# USER vncuser
# WORKDIR /home/vncuser

CMD ["supervisord", "-c", "/etc/supervisord.conf", "-n"]
