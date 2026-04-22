FROM alpine:3.23.3 AS build

ARG STUNNEL_VERSION=5.78
ARG OPENSSL_VERSION=1.0.2u

# TODO: Build args for stunnel and openssl

WORKDIR /app

RUN apk add --no-cache \
        build-base \
        wget \
        ca-certificates \
        perl \
    && export OPENSSL_GITHUB_RELEASE=OpenSSL_${OPENSSL_VERSION//./_} \
    && mkdir -p /app/dist \
    # Setting up openssl
    && wget -qO - https://github.com/openssl/openssl/releases/download/${OPENSSL_GITHUB_RELEASE}/openssl-${OPENSSL_VERSION}.tar.gz | tar xzvf - -C /app/dist/ \
    && cd /app/dist/openssl-${OPENSSL_VERSION}/ \
    && ./config -fPIC no-shared --prefix=/opt/openssl-${OPENSSL_VERSION} \
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
        --with-ssl=/opt/openssl-${OPENSSL_VERSION} \
    && make LDFLAGS="-all-static" \
    && make install \
    && cd /app \
    && rm -rf /app/dist/ /app/deps/

FROM alpine:3.23.3 AS runtime

WORKDIR /app

COPY --from=build /opt/stunnel/bin .

ENTRYPOINT [ "/app/stunnel" ]
