# MongoDB mit Custom Configuration
FROM mongo:7.0

# Build arguments for dynamic user creation
ARG ADDITIONAL_USERS
ARG MONGO_PORT

# Copy mongo configuration
COPY docker/mongo.conf /etc/mongod.conf

# Copy initialization scripts
COPY init-scripts/ /docker-entrypoint-initdb.d/

# Set environment variables for init scripts
ENV ADDITIONAL_USERS=${ADDITIONAL_USERS}
ENV MONGO_PORT=${MONGO_PORT}

# Copy startup script
COPY docker/startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# MongoDB mit Custom Config (Port wird aus mongo.conf gelesen)
ENTRYPOINT ["/usr/local/bin/startup.sh"]
CMD ["mongod", "--config", "/etc/mongod.conf", "--bind_ip_all", "--auth"]


