FROM debian:bullseye-slim AS build

ARG STUNNEL_VERSION=5.78

WORKDIR /app

# COPY conf/arm-linux-gnueabihf.conf /etc/ld.so.conf.d/arm-linux-gnueabihf.conf
COPY deps ./deps/

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        wget \
        ca-certificates \
    && update-ca-certificates \
    && mkdir -p /app/dist \
    # Setting up openssl
    && tar xzvf /app/deps/openssl-1.0.2q.tar.gz -C /app/dist/ \
    && cd /app/dist/openssl-1.0.2q/ \
    && ./config --prefix=/opt/openssl-1.0.2 \
        --openssldir=/etc/ssl \
        shared enable-weak-ssl-ciphers \
        enable-ssl3 enable-ssl3-method \
        enable-ssl2 \
        -Wl,-rpath=/opt/openssl-1.0.2/lib \
    && make \
    && make install \
    && cd /app \
    && ldconfig \
    && mkdir -p /app/dist \
    # Compiling stunnel
    && wget -qO - https://github.com/mtrojnar/stunnel/archive/refs/tags/stunnel-${STUNNEL_VERSION}.tar.gz | tar xzvf - -C /app/dist/ \
    && cd /app/dist/stunnel-stunnel-${STUNNEL_VERSION}/ \
    && LDFLAGS="-static" ./configure --prefix=/opt/stunnel-${STUNNEL_VERSION} --with-ssl=/opt/openssl-1.0.2  \
    && make \
    && make install \
    && cd /app \
    && rm -rf /app/dist/ /app/deps/

FROM scratch AS stunnel-runtime

ARG STUNNEL_VERSION=5.78

WORKDIR /app

COPY --from=build /opt/stunnel-${STUNNEL_VERSION} . 

ENTRYPOINT [ "/app/binstunnel" ]