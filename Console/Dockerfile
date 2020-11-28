FROM ubuntu:18.04
MAINTAINER Pradeep Tammali <pradeepkumartammali@gmail.com>
WORKDIR /cloud-console
ADD setup.sh setup.sh
ADD banner /etc/issue
ADD kubeconfig kubeconfig
ARG KUBELOGIN_VERSION="v1.22.0"
ARG HELM_VERSION="v3.4.1"
RUN apt update \
    && apt install vim curl jq unzip git -y \
    && chmod 755 /cloud-console/setup.sh \
    && echo "umask 077" >> /etc/profile \
    && echo "umask 077" >> /etc/bash.bashrc \
    && echo "/cloud-console/setup.sh" >> /etc/bash.bashrc \
    && echo "if [ $? -ne 0 ]; then" >> /etc/bash.bashrc \
    && echo "    exit 1" >> /etc/bash.bashrc \
    && echo "fi" >> /etc/bash.bashrc \
    && groupadd -g 100000 cloudconsole \
    && echo "exit 1" >> /root/.bashrc \
    # Installing kubectl
    && curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl \
    # Installing kubelogin
    && curl -Lo ./kubelogin.zip "https://github.com/int128/kubelogin/releases/download/$KUBELOGIN_VERSION/kubelogin_linux_amd64.zip" \
    && unzip ./kubelogin.zip \
    && rm ./kubelogin.zip LICENSE \
    && chmod +x ./kubelogin \
    && mv ./kubelogin /usr/local/bin/kubelogin \
    # Installing Helm
    && curl -Lo ./helm.tar.gz "https://get.helm.sh/helm-$HELM_VERSION-linux-amd64.tar.gz" \
    && tar -zxvf ./helm.tar.gz \
    && chmod +x linux-amd64/helm \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && rm -rf ./helm.tar.gz linux-amd64
