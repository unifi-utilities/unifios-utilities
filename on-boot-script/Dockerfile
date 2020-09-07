FROM debian:stretch-slim

RUN set -ex \
    && echo 'deb http://deb.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/backports.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
	build-essential \
        devscripts \
	fakeroot \
	debhelper=12.\* dh-autoreconf=17\* \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /tmp/* /var/tmp/* /var/log/* /var/lib/apt/lists/* /var/log/alternatives.log

RUN chmod a+rwx,u+t /tmp

ENTRYPOINT []
CMD ["/bin/sh"]
