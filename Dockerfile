FROM ubuntu:20.04
MAINTAINER cht.andy@gmail.com

ARG DEBIAN_FRONTEND=noninteractive

## 變更預設的dash 為bash
RUN set -x \
  && echo "######### dash > bash ##########" \
  && mv /bin/sh /bin/sh.old && ln -s /bin/bash /bin/sh

## 安裝locales 與預設語系
RUN set -x \
  && echo "######### apt install locales  ##########" \
  && apt-get update \
  && apt-get install --assume-yes locales \
  && rm -rf /var/lib/apt/lists/* && apt-get clean \
  && locale-gen zh_TW.UTF-8 && update-locale LANG=zh_TW.UTF-8

## 安裝supervisor
RUN set -x \
  && echo "######### apt install supervisor ##########" \
  && apt-get update && apt-get install --assume-yes supervisor bash-completion \ 
  && rm -rf /var/lib/apt/lists/* && apt-get clean \ 
  && { \
     echo "[supervisord]"; \
     echo "nodaemon=true"; \
     echo "logfile=/dev/null"; \
     echo "logfile_maxbytes=0"; \
     echo "pidfile=/tmp/supervisord.pid"; \
     } > /etc/supervisor/conf.d/supervisord.conf

# 安裝 vim 並設置 /etc/vim/vimrc
RUN set -x \
  && echo "######### apt install vim ##########" \
  && apt-get update && apt-get install vim -y \
  && rm -rf /var/lib/apt/lists/* && apt-get clean \
  && { \
     echo "set paste"; \
     echo "syntax on"; \ 
     echo "colorscheme torte"; \
     echo "set t_Co=256"; \
     echo "set nohlsearch"; \
     echo "set fileencodings=ucs-bom,utf-8,big5,gb18030,euc-jp,euc-kr,latin1"; \
     echo "set fileencoding=utf-8"; \
     echo "set encoding=utf-8"; \
     } >> /etc/vim/vimrc 

## 安裝sshd
RUN set -x \
  && echo "######### apt install sshd ##########" \
  && apt-get update \
  && apt-get install --assume-yes openssh-client openssh-server \
  && rm -rf /var/lib/apt/lists/* && apt-get clean \
  && sed -i 's|#PasswordAuthentication yes|PasswordAuthentication no|' /etc/ssh/sshd_config \
  && { \
     echo "    StrictHostKeyChecking no"; \
     echo "    UserKnownHostsFile /dev/null"; \
     } >> /etc/ssh/ssh_config \
  && echo "######### set sshd config with supervisor ##########" \
  && mkdir -p /run/sshd \
  && { \
     echo " "; \
     echo "[program:sshd]"; \
     echo "command=/usr/sbin/sshd -D"; \
     echo "autostart=true"; \
     echo "autorestart=true"; \
     echo "stdout_logfile=/proc/self/fd/1"; \
     echo "stderr_logfile=/proc/self/fd/2"; \
     } >> /etc/supervisor/conf.d/supervisord.conf

## 安裝ansible
ARG ANSIBLE_VERSION
RUN set -eux \
  && echo "######### install ansible ##########" \
  && apt-get update && apt-get install --assume-yes software-properties-common  \
  && apt-add-repository ppa:ansible/ansible-${ANSIBLE_VERSION} \
  && apt-get update \
  && apt-get install --assume-yes ansible \
  && rm -rf /var/lib/apt/lists/* && apt-get clean

## 安裝docker CLI
RUN set -x \
  && echo "######### install docker CLI ##########" \
  && apt-get update \
  && apt-get install --assume-yes apt-transport-https ca-certificates curl gnupg lsb-release \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
  && echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
  && apt-get update && apt-get install -y docker-ce-cli \
  && rm -rf /var/lib/apt/lists/* && apt-get clean 

## 新增user 並給予docker CLI 權限
ARG USERNAME
RUN set -x \
  && echo "######### useradd ${USERNAME} ##########" \
  && apt-get update \
  && apt install --assume-yes sudo \
  && rm -rf /var/lib/apt/lists/* && apt-get clean \
  && useradd -m -G sudo,root -u 1001 -s /bin/bash ${USERNAME} \
  && echo "${USERNAME} ALL=NOPASSWD: ALL" >> /etc/sudoers

ENTRYPOINT ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
