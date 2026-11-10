FROM ubuntu:22.04

ARG SALT_VERSION=3006.9

ENV container=docker \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      systemd-sysv \
      curl \
      ca-certificates \
      sudo \
      openssh-server \
      lsb-release \
      ruby \
      ruby-dev \
      git \
      patch \
 && rm -rf /var/lib/apt/lists/*

RUN touch /tmp/disable_salt_checks \
 && curl -fsSL https://github.com/saltstack/salt-bootstrap/releases/latest/download/bootstrap-salt.sh \
    | sh -s -- -X stable ${SALT_VERSION} \
 && rm -rf /var/cache/salt \
 && for f in /opt/saltstack/salt/salt-*; do ln -sf "$f" "/usr/local/bin/$(basename $f)"; done

COPY patch/ /tmp/patch/
RUN SALT_MAJOR=$(echo "${SALT_VERSION}" | cut -d. -f1) \
 && if [ -f "/tmp/patch/salt-ssh-target-modules-${SALT_MAJOR}.patch" ]; then \
      SITE_PKG=$(find /opt/saltstack/salt/lib -maxdepth 1 -name 'python3.*')/site-packages; \
      patch -p1 -d "$SITE_PKG" < "/tmp/patch/salt-ssh-target-modules-${SALT_MAJOR}.patch"; \
    fi \
 && rm -rf /tmp/patch

RUN curl -fsSL https://raw.githubusercontent.com/saltstack/kitchen-salt/master/assets/install.sh \
    | sh

CMD ["/lib/systemd/systemd"]
