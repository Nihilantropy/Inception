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

# Copy the project files (adjust for your project structure)
COPY ./ /app


RUN npm install

# Install Gatsby CLI globally
RUN npm install -g gatsby-cli

# Build the Gatsby site
RUN gatsby clean && gatsby build

# Install a lightweight static file server
RUN npm install -g serve

# Expose the default static file server port
EXPOSE 3000

# Serve the Gatsby static site
CMD ["serve", "-s", "public", "-l", "3000"]
