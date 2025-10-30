FROM nginx:stable-alpine

# Copy template and start script
COPY nginx/nginx.conf.template /etc/nginx/nginx.conf.template
COPY nginx/start.sh /start.sh

# Make script executable
RUN chmod +x /start.sh

CMD ["/start.sh"]
