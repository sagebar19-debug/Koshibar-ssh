FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        stunnel4 \
        nodejs \
        ca-certificates \
        bash \
        procps && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p \
        "/Koshibar/100%/tls" \
        "/Koshibar/100%/data/home" \
        /run/sshd

COPY Proxy3.js "/Koshibar/100%/Proxy3.js"
COPY Exécuter.sh "/Koshibar/100%/Exécuter.sh"
COPY Stunnel.conf "/Koshibar/100%/Stunnel.conf"

RUN chmod +x "/Koshibar/100%/Exécuter.sh"

EXPOSE 22 8080 8443

WORKDIR "/Koshibar/100%"

CMD ["/Koshibar/100%/Exécuter.sh"]
