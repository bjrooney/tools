# docker build -t doctl_local --build-arg DOCTL_VERSION=1.93.1 .
#
# This Dockerfile exists so casual uses of `docker build` and `docker run` do something sane.
# We don't recommend using it: If you want to develop in docker, please use `make docker_build`
# instead.

FROM alpine:latest

ENV DISPLAY :1
# alternative 1024x768x16
ENV RESOLUTION 1920x1080x24

ENV VENDIR_VERSION=0.42.0
ENV KLUCTL_VERSION=2.25.1
ENV TERRAFORM_VERSION=1.9.7
ENV KUBECTL_VERSION=1.31.1
ENV KUBELOGIN_VERSION=0.1.4
ENV HELMFILE_VERSION=0.168.0
ENV HELM_VERSION=3.16.0
ENV PWSH_VERSION=7.4.1
ENV TERRASPACE_VERSION=latest
ENV AZCLI_VERSION=2.65.0
ENV K9S_VERSION=0.32.5

ENV PATH=${PATH}:/root/.krew/bin:/root/.arkade/bin:/root/.linkerd2/bin:/root/.nvm
RUN touch /root/.bashrc
RUN touch /root/.bash_profile
RUN touch /root/.zshrc
RUN touch /root/.profile


WORKDIR /root
RUN apk add --update --no-cache \
            supervisor \
            busybox-extras \
            # firefox\
            python3 \
            py3-pip \
            ncurses \
            openssl \
            tree \
            vim \
            jq \
            util-linux \
            sed \
            # x11vnc \
            # xvfb \
            ttf-dejavu \
            # xfce4 \
            # faenza-icon-theme \
            # gnome-terminal \
            # xterm \
            bash \
            zsh \
            # desktop-file-utils \
            # adwaita-icon-theme \
            # ttf-dejavu \
            # ffmpeg-libs \
            curl \
            nodejs \
            npm \
            gcc \
            git 

SHELL       ["/bin/bash", "-c"]

# Install powershell
RUN cd "$(mktemp -d)" \
    && wget "https://github.com/PowerShell/PowerShell/releases/download/v${PWSH_VERSION}/powershell-${PWSH_VERSION}-linux-x64.tar.gz" \
    && tar zxvf powershell-${PWSH_VERSION}-linux-x64.tar.gz -C /bin \
    && chmod +x /bin/pwsh 

# Install helm
RUN cd "$(mktemp -d)" \
    && wget https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && tar zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/bin \
    && helm plugin install https://github.com/databus23/helm-diff

# Install helmfile
RUN cd "$(mktemp -d)" \
    && 	wget https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz \
    && 	tar zxvf helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz \
    &&  mv helmfile /usr/bin/helmfile

# Install kubectl
RUN cd "$(mktemp -d)" \
    && curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/bin/kubectl

# Install kubelogin
RUN cd "$(mktemp -d)" \
    && wget https://github.com/Azure/kubelogin/releases/download/v${KUBELOGIN_VERSION}/kubelogin-linux-amd64.zip \
    && unzip kubelogin-linux-amd64.zip \
    && mv bin/linux_amd64/kubelogin /usr/bin/kubelogin



# Install terraform
RUN cd "$(mktemp -d)" \
    && curl "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/bin/terraform

# # Install terraspace
# RUN wget https://apt.boltops.com/packages/terraspace/terraspace-${TERRASPACE_VERSION}.deb \
#     && dpkg -i terraspace-${TERRASPACE_VERSION}.deb

# Install vendir
RUN cd "$(mktemp -d)" \
    && curl -s -L https://github.com/carvel-dev/vendir/releases/download/v${VENDIR_VERSION}/vendir-linux-amd64 > /usr/bin/vendir \
    && chmod +x /usr/bin/vendir 

# Install kluctl
RUN cd "$(mktemp -d)" \
    && export kluctl_VERSION=${KLUCTL_VERSION} \
    && curl -s https://kluctl.io/install.sh | bash

# Install krew
RUN cd "$(mktemp -d)" \
    && curl -LO https://github.com/kubernetes-sigs/krew/releases/download/v0.4.4/krew-linux_amd64.tar.gz \
    && tar zxvf krew-linux_amd64.tar.gz \
    &&  ./krew-linux_amd64 install krew \
&& kubectl krew update \
&& kubectl krew install kc ns ctx cert-manager starboard view-utilization bd-xray status topology janitor graph flame

# Install k9s
RUN cd "$(mktemp -d)" \
    && curl -LO https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz \
    && tar zxvf k9s_Linux_amd64.tar.gz -C /usr/bin

# Install aws cli
RUN cd "$(mktemp -d)" \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

RUN cd "$(mktemp -d)" \
  && curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-415.0.0-linux-x86_64.tar.gz \
  && tar zxvf google-cloud-cli-415.0.0-linux-x86_64.tar.gz \
  && cd google-cloud-sdk \
  && chmod +x install.sh \
  && /bin/sh install.sh -q  
  # && gcloud --version

RUN cd "$(mktemp -d)" \
  && curl -L https://github.com/cli/cli/releases/download/v2.22.0/gh_2.22.0_linux_amd64.tar.gz -o gh.tar.gz \
  && tar zxvf gh.tar.gz \
  && cd gh_2.22.0_linux_amd64/bin \
  && chmod +x gh \
  && mv ./gh /usr/local/bin/ \
  && gh --version 


RUN cd "$(mktemp -d)" \
  && curl -L https://github.com/gimlet-io/gimlet-cli/releases/download/v0.3.0/gimlet-$(uname)-$(uname -m) -o gimlet \
&& chmod +x gimlet \
&& mv ./gimlet /usr/local/bin/gimlet \
&& gimlet --version

RUN cd "$(mktemp -d)" \
  && git clone https://github.com/andrey-pohilko/registry-cli.git \
&& pip3 install -r registry-cli/requirements-build.txt \
&& python3 /root/registry-cli/registry.py || :
 
# RUN adduser -D -s /bin/bash -h /home/vncuser vncuser

# # setup supervisor
# COPY supervisor /tmp

# RUN echo_supervisord_conf > /etc/supervisord.conf && \
#   sed -i -r -f /tmp/supervisor.sed /etc/supervisord.conf && \
#   mkdir -pv /etc/supervisor/conf.d /var/log/{novnc,x11vnc,xfce4,xvfb} && \
#   mv /tmp/supervisor-*.ini /etc/supervisor/conf.d/ && \
#   rm -fr /tmp/supervisor*
# RUN chmod -Rf 777 /etc/supervisor/conf.d/ 
# RUN chmod 777 /etc/supervisord.conf
# RUN chmod -Rf 777 /var/log
# # USER vncuser
# # WORKDIR /home/vncuser

# CMD ["supervisord", "-c", "/etc/supervisord.conf", "-n"]
