FROM alpine:3.20 AS assets
WORKDIR /site
COPY site/ ./
RUN find . -type f \( -name '*.css' -o -name '*.js' -o -name '*.svg' \) -exec gzip -9 -k {} \;

FROM nginxinc/nginx-unprivileged:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=assets /site /usr/share/nginx/html
EXPOSE 8080
USER 101
