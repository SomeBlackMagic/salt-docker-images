FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive

ARG SALT_VERSION=3006.9

# -----------------------------
# system deps
# -----------------------------
RUN apt update && apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    python3-pip \
    openssh-client \
    rsync \
    git \
    nano \
    bash-completion \
    mc \
    && rm -rf /var/lib/apt/lists/*


# -----------------------------
# Salt APT repository (Broadcom)
# -----------------------------
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL \
      https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public \
      | gpg --dearmor -o /etc/apt/keyrings/salt-archive-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/salt-archive-keyring.gpg] \
      https://packages.broadcom.com/artifactory/saltproject-deb \
      stable main" \
      > /etc/apt/sources.list.d/salt.list


# -----------------------------
# install Salt packages
# -----------------------------
RUN apt update && apt install -y \
    salt-common=${SALT_VERSION}* \
    salt-minion=${SALT_VERSION}* \
    salt-master=${SALT_VERSION}* \
    salt-ssh=${SALT_VERSION}* \
    salt-cloud=${SALT_VERSION}* \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://raw.githubusercontent.com/saltstack/salt/develop/pkg/salt.bash \
    -o /etc/bash_completion.d/salt.bash

#RUN chown -R sre:sre /opt/saltstack/salt


WORKDIR /workspace

ENV SALT_CONFIG_DIR=/workspace/etc/salt
ENV SALT_FILE_ROOT=/workspace/srv/salt
ENV SALT_PILLAR_ROOT=/workspace/srv/pillar
ENV SALT_CACHEDIR=/workspace/var/cache/salt
ENV SALT_LOGDIR=/workspace/var/log/salt
ENV SALT_PKI_DIR=/workspace/pki/salt


COPY --chmod=644 bash.bashrc /etc/bash.bashrc

COPY --chmod=777 ./docker-entrypoint.sh /docker-entrypoint.sh
COPY ./docker-entrypoint.d /docker-entrypoint.d

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["bash"]
