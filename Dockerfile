# Dockerfile for OXO Menus Web Application

# Stage 1: Build Flutter web app
FROM ghcr.io/cirruslabs/flutter:3.24.0 AS builder

WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Install dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Run code generation
RUN flutter pub run build_runner build --delete-conflicting-outputs

# Build web app
ARG DIRECTUS_URL=http://localhost:8055
RUN flutter build web --release --dart-define=DIRECTUS_URL=${DIRECTUS_URL}

# Stage 2: Serve with nginx
FROM nginx:alpine

# Copy built web app to nginx
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
