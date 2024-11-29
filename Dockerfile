FROM golang:1.23.3-alpine AS builder
WORKDIR /app

# https://tailscale.com/kb/1118/custom-derp-servers/
RUN go install tailscale.com/cmd/derper@latest

FROM alpine
WORKDIR /app

RUN apk update \
    && apk --no-cache add --no-check-certificate ca-certificates \
    && update-ca-certificates

ENV DERP_DOMAIN your-hostname.com
ENV DERP_CERT_MODE letsencrypt
ENV DERP_CERT_DIR /certs
ENV DERP_CONFIG_PATH /config/derp.conf
ENV DERP_ADDR :443
ENV DERP_STUN true
ENV DERP_STUN_PORT 3478
ENV DERP_HTTP_PORT 80
ENV DERP_VERIFY_CLIENTS false
ENV DERP_VERIFY_CLIENT_URL ""

COPY --from=builder /go/bin/derper .

CMD /app/derper -hostname=$DERP_DOMAIN \
    -certmode=$DERP_CERT_MODE \
    -certdir=$DERP_CERT_DIR \
    -c=$DERP_CONFIG_PATH \
    -a=$DERP_ADDR \
    -stun=$DERP_STUN  \
    -stun-port=$DERP_STUN_PORT \
    -http-port=$DERP_HTTP_PORT \
    -verify-clients=$DERP_VERIFY_CLIENTS \
    -verify-client-url=$DERP_VERIFY_CLIENT_URL

