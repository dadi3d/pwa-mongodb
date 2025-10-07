# MongoDB mit Custom Startup Script
FROM mongo:7.0

# Copy startup script und mache es ausführbar
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

# Setze Custom Entrypoint
ENTRYPOINT ["/startup.sh"]

# Standard MongoDB Command
CMD ["mongod", "--bind_ip_all", "--auth"]