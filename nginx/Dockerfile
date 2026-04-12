FROM nginx:stable-alpine

# Copy main nginx configuration with includes
COPY nginx.conf /etc/nginx/nginx.conf

# Create directories for configs and certbot webroot
RUN mkdir -p /etc/nginx/conf.d /var/www/certbot

# Expose HTTP and HTTPS (non-privileged ports for rootless Docker)
EXPOSE 8080 8443

# Healthcheck - check port 8080
HEALTHCHECK --interval=30s --timeout=5s CMD curl -f http://localhost:8080/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
