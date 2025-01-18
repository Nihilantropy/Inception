FROM alpine:3.19

# Install Python and dependencies
RUN apk update && apk add --no-cache \
    python3 \
    py3-pip \
    py3-prometheus-client

# Set the working directory
WORKDIR /app

# Copy the application files into the container
COPY /src .

COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

# Expose the port where the app will be running
EXPOSE 8060 8000

# init script to initial checks and server start
ENTRYPOINT ["/init.sh"]