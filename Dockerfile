FROM alpine:3.23.3 AS build

ARG STUNNEL_VERSION=5.78

# TODO: Build args for stunnel and openssl

WORKDIR /app

COPY deps ./deps/

RUN apk add --no-cache \
        build-base \
        wget \
        ca-certificates \
        perl \
    && mkdir -p /app/dist \
    # Setting up openssl
    && tar xzvf /app/deps/openssl-1.0.2q.tar.gz -C /app/dist/ \
    && cd /app/dist/openssl-1.0.2q/ \
    && ./config -fPIC no-shared --prefix=/opt/openssl-1.0.2 \
        --openssldir=/etc/ssl \
        enable-weak-ssl-ciphers \
        enable-ssl3 \
        enable-ssl3-method \
        enable-ssl2 \
    && make \
    && make install \
    && cd /app \
    && mkdir -p /app/dist \
    # Compiling stunnel
    && wget -qO - https://github.com/mtrojnar/stunnel/archive/refs/tags/stunnel-${STUNNEL_VERSION}.tar.gz | tar xzvf - -C /app/dist/ \
    && cd /app/dist/stunnel-stunnel-${STUNNEL_VERSION}/ \
    && CFLAGS='-Os -fomit-frame-pointer -pipe' ./configure \
        --enable-static \
        --disable-fips \
        --disable-silent-rules \
        --disable-shared \
        --prefix=/opt/stunnel \
        --with-ssl=/opt/openssl-1.0.2 \
    && make LDFLAGS="-all-static" \
    && make install \
    && cd /app \
    && rm -rf /app/dist/ /app/deps/

FROM alpine:3.23.3 AS runtime

WORKDIR /app

COPY --from=build /opt/stunnel/bin .

ENTRYPOINT [ "/app/stunnel" ]
