FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        nodejs \
        ca-certificates \
        bash \
        procps && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p \
        "/Koshibar/100%/data/home" \
        /run/sshd

COPY Proxy3.js "/Koshibar/100%/Proxy3.js"
COPY Exécuter.sh "/Koshibar/100%/Exécuter.sh"

RUN chmod +x "/Koshibar/100%/Exécuter.sh"

WORKDIR "/Koshibar/100%"

EXPOSE 8080

CMD ["/Koshibar/100%/Exécuter.sh"]
