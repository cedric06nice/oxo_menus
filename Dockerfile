# Dockerfile for OXO Menus Web Application

# Stage 1: Build Flutter web app
FROM ghcr.io/cirruslabs/flutter:3.41.0 AS builder

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY ./ ./
RUN flutter pub run build_runner build --delete-conflicting-outputs

ARG DIRECTUS_URL=http://localhost:8055
RUN flutter build web --release --dart-define=DIRECTUS_URL=${DIRECTUS_URL}

# Stage 2: Serve with nginx
FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
