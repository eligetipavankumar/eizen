FROM nginx:alpine

# Remove default nginx.conf to avoid conflict
RUN rm -f /etc/nginx/nginx.conf

# Copy entire nginx config directory
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/conf.d/* /etc/nginx/conf.d/

# Create log directory and set permissions
RUN mkdir -p /var/log/nginx && chown -R nginx:nginx /var/log/nginx

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
