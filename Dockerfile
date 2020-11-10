FROM maven:3.6.3-adoptopenjdk-11

ENV DOCKER_VERSION=19.03.13

RUN apt-get update && \
    apt-get install -y apt-transport-https wget gnupg2 && \
    rm -rf /var/lib/apt/lists/* && \
    URL="https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" && \
    wget -O docker.tgz "$URL" && \
    tar --extract \
		--file docker.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ && \
    rm docker.tgz && \
    dockerd --version && \
    docker --version

COPY modprobe.sh /usr/local/bin/modprobe
#COPY docker-entrypoint.sh /usr/local/bin/

# https://github.com/docker-library/docker/pull/166
#   dockerd-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-generating TLS certificates
#   docker-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-setting DOCKER_TLS_VERIFY and DOCKER_CERT_PATH
# (For this to work, at least the "client" subdirectory of this path needs to be shared between the client and server containers via a volume, "docker cp", or other means of data sharing.)
ENV DOCKER_TLS_CERTDIR=/certs
# also, ensure the directory pre-exists and has wide enough permissions for "dockerd-entrypoint.sh" to create subdirectories, even when run in "rootless" mode
RUN mkdir /certs /certs/client && chmod 1777 /certs /certs/client
# (doing both /certs and /certs/client so that if Docker does a "copy-up" into a volume defined on /certs/client, it will "do the right thing" by default in a way that still works for rootless users)

#ENTRYPOINT ["docker-entrypoint.sh"]
#CMD ["sh"]
