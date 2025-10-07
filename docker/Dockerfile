# MongoDB mit Custom Configuration
FROM mongo:7.0

# Copy mongo configuration
COPY docker/mongo.conf /etc/mongod.conf

# Standard MongoDB Command mit Custom Config
CMD ["mongod", "--config", "/etc/mongod.conf", "--bind_ip_all", "--auth"]