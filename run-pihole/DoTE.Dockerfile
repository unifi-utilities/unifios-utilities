ARG PIHOLE_DOCKER_TAG=2023.02.2
FROM pihole/pihole:${PIHOLE_DOCKER_TAG}
ENV DEBIAN_FRONTEND="noninteractive"
ENV DOTE_OPTS="-s 127.0.0.1:5053"
RUN curl -fsSLo /opt/dote https://github.com/chrisstaite/DoTe/releases/latest/download/dote_arm64 && \
  chmod +x /opt/dote && \
  usermod -aG pihole www-data; \
  mkdir -p /etc/cont-init.d && \
  echo -e "#!/bin/bash\nchmod +x /opt/dote\n/opt/dote \$DOTE_OPTS -d\n" > /etc/cont-init.d/10-dote.sh && \
  chmod +x /etc/cont-init.d/10-dote.sh
