FROM debian:buster-slim

RUN set -ex \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        curl \
    && echo 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_10/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list \
    && (curl -sSL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_10/Release.key | apt-key add -) \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	build-essential \
        devscripts \
	fakeroot \
	debhelper \
        qemu-user-static \
        buildah \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /tmp/* /var/tmp/* /var/log/* /var/lib/apt/lists/* /var/log/alternatives.log

RUN chmod a+rwx,u+t /tmp

ENTRYPOINT []
CMD ["/bin/sh"]
