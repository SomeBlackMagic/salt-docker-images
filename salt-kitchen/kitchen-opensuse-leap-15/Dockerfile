FROM opensuse/leap:15

ARG SALT_VERSION=3006.9

ENV container=docker

RUN zypper --non-interactive install --no-recommends \
      sudo \
      openssh \
      openssh-server \
      which \
      curl \
      gawk \
      systemd \
      ca-certificates \
      ruby \
      ruby-devel \
      git \
 && zypper clean --all

RUN touch /tmp/disable_salt_checks \
 && curl -fsSL https://github.com/saltstack/salt-bootstrap/releases/latest/download/bootstrap-salt.sh \
    | sh -s -- -X -M -S -W -L -y -Y stable ${SALT_VERSION} \
 && rm -rf /var/cache/salt


RUN curl -fsSL https://raw.githubusercontent.com/saltstack/kitchen-salt/master/assets/install.sh \
    | sh

CMD ["/usr/lib/systemd/systemd"]
