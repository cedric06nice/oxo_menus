# Dockerfile for OXO Menus Web Application
# Uses pre-built Flutter web output from CI — no rebuild needed.

FROM nginx:alpine

COPY build/web/ /usr/share/nginx/html/
COPY deploy/docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://127.0.0.1/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
