FROM alpine:3.19

# Install Python and dependencies
RUN apk update && apk add --no-cache \
    python3 \
    py3-pip \
    py3-prometheus-client

# Set the working directory
WORKDIR /app

# Copy only the source files first
COPY src/ /app/src/

ENV PYTHONUNBUFFERED=1

# Expose the ports
EXPOSE 8060 8000

# Start the server
CMD ["python3", "/app/src/serve.py", "--root", "/app/src", "--no-browser", "--port", "8060", "--metrics-port", "8000"]