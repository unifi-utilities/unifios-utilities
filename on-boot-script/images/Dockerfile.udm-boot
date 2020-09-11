FROM localhost/podman

RUN set -ex \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        procps \
        net-tools \
        vim \
        cockpit \
    && systemctl enable cockpit.socket \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /tmp/* /var/tmp/* /var/log/* /var/lib/apt/lists/* /var/log/alternatives.log

RUN /bin/bash -c 'echo -e "udm-boot\nudm-boot" |(passwd root)'

# cockpit
EXPOSE 9090/tcp
