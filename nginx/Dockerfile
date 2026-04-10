FROM nginx:alpine

# Install certbot for Let's Encrypt (if needed)
RUN apk add --no-cache certbot

# Copy main nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy site configurations
COPY conf.d/ /etc/nginx/conf.d/

# Create certbot webroot
RUN mkdir -p /var/www/certbot

# Expose HTTP and HTTPS (non-privileged ports for rootless Docker)
EXPOSE 8080 8443

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
