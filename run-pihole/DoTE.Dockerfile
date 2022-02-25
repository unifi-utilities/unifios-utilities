ARG VERSION=2022.02.1
FROM pihole/pihole:${VERSION}
ENV DOTE_OPTS="-s 127.0.0.1:5053"
RUN echo -e  "#!/bin/sh\ncurl -fsSLo /opt/dote https://github.com/chrisstaite/DoTe/releases/latest/download/dote_arm64\nchmod +x /opt/dote\n/opt/dote \\\$DOTE_OPTS -d\n" > /etc/cont-init.d/10-dote.sh

