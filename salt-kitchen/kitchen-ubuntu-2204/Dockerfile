FROM ubuntu:22.04

ARG SALT_VERSION=3006.9

ENV container=docker \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      systemd-sysv \
      curl \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

RUN touch /tmp/disable_salt_checks \
 && curl -fsSL https://github.com/saltstack/salt-bootstrap/releases/latest/download/bootstrap-salt.sh \
    | sh -s -- -X stable ${SALT_VERSION} \
 && rm -rf /var/cache/salt

RUN curl -fsSL https://raw.githubusercontent.com/saltstack/kitchen-salt/master/assets/install.sh \
    | sh

CMD ["/lib/systemd/systemd"]
