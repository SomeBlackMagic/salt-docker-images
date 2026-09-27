FROM quay.io/centos/centos:stream9

ARG SALT_VERSION=3006.9

RUN yum install -y sudo openssh-server openssh-clients which
RUN dnf install -y --allowerasing systemd curl \
 && dnf clean all

RUN touch /tmp/disable_salt_checks \
 && curl -fsSL https://github.com/saltstack/salt-bootstrap/releases/latest/download/bootstrap-salt.sh \
    | sh -s -- -X stable ${SALT_VERSION} \
 && rm -rf /var/cache/salt

RUN curl -fsSL https://raw.githubusercontent.com/saltstack/kitchen-salt/master/assets/install.sh \
    | sh

CMD ["/usr/lib/systemd/systemd"]
