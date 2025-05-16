FROM arm32v5/debian:latest AS builder

RUN apt-get update && apt-get install -y make gcc git libc-dev openssh-client

WORKDIR /tmp
RUN git clone https://github.com/pcherenkov/udpxy.git \
    && cd udpxy/chipmunk \
    && make && make install


FROM arm32v5/debian:latest

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    net-tools \
    iproute2 \
    iputils-ping \
    procps \
    curl \
    dnsutils \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/udpxy /usr/local/bin/udpxy
COPY --from=builder /usr/local/bin/udpxrec /usr/local/bin/udpxrec

EXPOSE 4022

ENTRYPOINT ["/usr/local/bin/udpxy", "-T", "-p", "4022", "-m", "eth0", "-c", "1"]

