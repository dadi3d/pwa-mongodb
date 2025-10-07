# MongoDB mit Custom Configuration
FROM mongo:7.0

# Copy mongo configuration
COPY docker/mongo.conf /etc/mongod.conf

# MongoDB mit Custom Config (Port wird aus mongo.conf gelesen)
CMD ["mongod", "--config", "/etc/mongod.conf", "--bind_ip_all", "--auth"]