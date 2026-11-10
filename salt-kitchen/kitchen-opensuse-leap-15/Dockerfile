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
      patch \
 && zypper clean --all

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

RUN mkdir -p /opt/chef/embedded/bin \
 && ln -sf "$(which ruby)" /opt/chef/embedded/bin/ruby \
 && ln -sf "$(which gem)" /opt/chef/embedded/bin/gem

CMD ["/usr/lib/systemd/systemd"]
