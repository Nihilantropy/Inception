# Base image
FROM alpine:3.19

# Set working directory
WORKDIR /app

# Install Node.js, npm, and other required dependencies
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    bash \
    curl

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies
RUN npm install

# Install global packages
RUN npm install -g gatsby-cli serve

# Now copy the rest of the application
COPY . .

# Build the Gatsby site
RUN gatsby clean && gatsby build

# Setup init script
RUN mv /app/tools/init.sh / && \
    chmod +x /init.sh && \
    rm -rf /app/tools

# Expose the default static file server port
EXPOSE 3000

# Init script to initial checks and server start
ENTRYPOINT ["/init.sh"]