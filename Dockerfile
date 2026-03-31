FROM ghcr.io/getzola/zola:v0.21.0 AS build

ARG ZOLA_CONFIG=config.toml

WORKDIR /src

COPY . /src

COPY ${ZOLA_CONFIG} config.toml

RUN [ "zola", "build" ]

FROM nginx:1.29.3-alpine

COPY ./nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /src/public /usr/share/nginx/html/

EXPOSE 80 443
