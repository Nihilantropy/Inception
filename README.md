<!--=====================================
=           INTRODUCTION              =
======================================-->
# Introduction to Inception 🚀

A comprehensive guide to building a containerized web infrastructure.

<!--=====================================
=         TABLE OF CONTENTS           =
======================================-->
## Table of Contents 📚

1. [Introduction to Inception](#introduction-to-inception)
   - [What is Inception?](#what-is-inception)
   - [Project Goals](#project-goals)
   - [Architecture Overview](#architecture-overview)
   - [Key Technical Requirements](#key-technical-requirements)
   - [Project Structure](#project-structure)

2. [Docker Fundamentals](#docker-fundamentals)
   - [What is Docker?](#what-is-docker)
   - [Why Docker?](#why-docker)
   - [Key Docker Components](#key-docker-components)
   - [Docker in Inception Project](#docker-in-inception-project)

[Content of previous sections follows...]

<!--=====================================
=         PROJECT OVERVIEW            =
======================================-->
## What is Inception?

Inception is an advanced system administration project that challenges you to build and orchestrate a complete infrastructure using Docker containerization. The project simulates a real-world production environment where multiple services work together to deliver a robust web application stack.

<!--=====================================
=         PROJECT GOALS               =
======================================-->
## Project Goals 🎯

The main objectives of Inception are:

1. **Containerization Mastery**: Learn to build and manage Docker containers from scratch, without using pre-built images
2. **Service Orchestration**: Create a multi-service infrastructure where each component runs in its own container
3. **Infrastructure as Code**: Implement all configurations through scripts, ensuring reproducibility and maintainability
4. **Security Implementation**: Set up secure communication between services and implement proper access controls

<!--=====================================
=       ARCHITECTURE OVERVIEW         =
======================================-->
## Architecture Overview 🏗️

The Inception infrastructure consists of:

### 1. Mandatory Services
- 🌐 **NGINX**: Acts as a reverse proxy with SSL/TLS termination  
- 🖥️ **WordPress + PHP-FPM**: Main application server  
- 🗄️ **MariaDB**: Database server for persistent data storage  

### 2. Bonus Services
- ⚡ **Redis**: Caching system for WordPress optimization  
- 📂 **VSFTPD**: FTP server for file management  
- 📊 **Adminer**: Database management interface  
- 🚀 **Gatsby**: Static site generator for additional content  
- 🎮 **Custom Game Integration**: Demonstrating versatile deployment capabilities  

### 3. Additional Services
- 📈 **Prometheus**: Metrics collection and storage  
- 📉 **Grafana**: Visualization and dashboard creation  
- 🛠️ **cAdvisor**: Container metrics collection

![Inception Architecture](images/inception-architecture.png)

*Note: The monitoring services are neither part of the mandatory requirements nor the bonus part. They were added as a learning exercise to explore container monitoring.*

<!--=====================================
=     TECHNICAL REQUIREMENTS          =
======================================-->
## Key Technical Requirements 📋

1. **Base Image Choice**
   - Containers must use either Alpine Linux or Debian as their base image
   - In this implementation, we chose Alpine Linux (rationale detailed in later sections)
   - Custom Dockerfiles must be written for each service
   - No use of pre-built Docker images from Docker Hub

2. **Container Organization**
   - Each service runs in its dedicated container
   - Services must automatically restart on failure
   - Proper resource isolation between containers

3. **Data Management**
   - Persistent data storage through Docker volumes
   - Efficient backup and restore capabilities
   - Data integrity across container restarts

4. **Networking**
   - Isolated Docker networks for different service groups
   - Secure internal communication
   - External access only through designated ports

5. **Configuration**
   - All setup performed through initialization scripts
   - Environment variable management
   - No manual intervention in container configuration

<!--=====================================
=         PROJECT STRUCTURE           =
======================================-->
## Project Structure 📁

The project follows a clear organizational structure:

```
inception/
├── srcs/
│   ├── docker-compose.yml
│   └── requirements/
│       ├── nginx/
│       ├── wordpress/
│       ├── mariadb/
│       └── bonus/
│           ├── redis/
│           ├── ftp/
│           ├── adminer/
│           ├── gatsby-app/
│           └── monitoring/  # Additional services
└── Makefile
```

This structure ensures:
- Clear separation of services
- Easy maintenance and updates
- Scalable architecture
- Efficient development workflow

The Inception project represents a comprehensive approach to modern infrastructure deployment, combining security, efficiency, and maintainability in a containerized environment. 🌟

<!--=====================================
=         DOCKER FUNDAMENTALS         =
======================================-->
# Docker Fundamentals 🐳

## What is Docker?

Docker is a platform for developing, shipping, and running applications in isolated environments called containers. A container is a lightweight, standalone package that includes everything needed to run a piece of software - from the code and runtime to system libraries and settings.

![VM vs Containers](images/vm-vs-containers.png)

<!--=====================================
=         DOCKER BENEFITS             =
======================================-->
## Why Docker? 🤔

Docker solves several key challenges in modern software development:

1. **Consistency**: "It works on my machine" becomes a problem of the past
2. **Isolation**: Applications run independently without interfering with each other
3. **Efficiency**: Containers share the host OS kernel, making them lighter than VMs
4. **Scalability**: Easy to deploy multiple instances of the same application

## Key Docker Components 🔧

- **Dockerfile**: A text file containing instructions to build an image
- **Image**: A template for creating containers (like a snapshot)
- **Container**: A running instance of an image
- **Docker Compose**: Tool for defining and running multi-container applications

<!--=====================================
=         DOCKER IN INCEPTION         =
======================================-->
## Docker in Inception Project 🎯

### Traditional Docker vs. Inception Approach

**Traditional Approach:**
```bash
# Pulling pre-built images
docker pull wordpress:latest
docker pull mysql:latest
```

**Inception Approach:**
```dockerfile
# Building custom WordPress image
FROM alpine:3.19
RUN apk add --no-cache php php-fpm wordpress
# Custom configurations...
```

<!-- <ADD IMAGE: "Visual comparison between Traditional Docker Approach (pulling images) vs Inception Approach (building from scratch), showing the layers and components involved in each approach">

![Docker Approaches](images/docker-approaches.png) -->

### Why Build From Scratch?

1. **Understanding**: Gain deep knowledge of service configuration
2. **Control**: Full control over what goes into each container
3. **Security**: Minimize vulnerabilities by including only necessary components
4. **Optimization**: Create lean containers tailored to specific needs

### Project Implementation

In Inception, we:
- Write custom Dockerfiles for each service
- Configure services through initialization scripts
- Use docker-compose for orchestration
- Implement proper networking and volume management

This approach provides valuable learning opportunities and better control over the infrastructure, though in production environments, validated official images might be preferred for their reliability and maintenance.

<!--=====================================
=         ALPINE LINUX                =
======================================-->
# All Alpine 🏔️

## The Alpine Choice

In Inception, we had the choice between Debian and Alpine Linux as base images for our containers. We chose Alpine Linux for all our services, a decision that brings specific advantages to our containerized infrastructure.

<!--=====================================
=         ALPINE BENEFITS             =
======================================-->
## Why Alpine? 

### Size Matters 📦
- **Minimal Base Image**: Alpine base image is ~5MB compared to Debian's ~114MB
- **Smaller Final Images**: Services built on Alpine typically result in 30-70% smaller images
- **Faster Deployments**: Smaller images mean quicker pulls and deployments

### Security First 🛡️
- **Minimal Attack Surface**: Fewer installed packages means fewer potential vulnerabilities
- **Security-oriented**: Built with security in mind from the ground up
- **Regular Security Updates**: Active maintenance and quick security patches

### Package Management 🔧
- **Simple Package Manager**: `apk` is fast, simple, and efficient
- **Rich Package Repository**: Despite its size, Alpine provides most needed packages
- **Quick Updates**: Package installation and updates are notably faster than apt

<!-- <ADD IMAGE: "Size comparison chart showing Alpine vs Debian base image sizes and final container sizes for each service in Inception">

![Alpine vs Debian Sizes](images/alpine-debian-comparison.png) -->

<!--=====================================
=         ALPINE IMPLEMENTATION       =
======================================-->
## Implementation in Inception

### Base Image Declaration
```dockerfile
# All our Dockerfiles start with
FROM alpine:3.19
```

### Package Installation Pattern
```dockerfile
# Alpine's efficient package installation
RUN apk update && apk add --no-cache \
    package1 \
    package2 \
    package3
```

### Key Considerations

1. **Compatibility**
   - Most services work seamlessly on Alpine
   - Some packages might have slightly different names than in Debian
   - Occasional need to install additional dependencies

2. **Learning Curve**
   - Different package names from Debian/Ubuntu
   - Simpler init system
   - Streamlined configuration approaches

3. **Advantages in Our Setup**
   - Reduced resource usage across all containers
   - Faster container startup times
   - Simplified dependency management

<!--=====================================
=         SERVICE BENEFITS            =
======================================-->
## Impact on Services

Each service benefits from Alpine in specific ways:

- **NGINX**: Lightweight reverse proxy with minimal overhead
- **WordPress**: Efficient PHP-FPM implementation
- **MariaDB**: Optimized database server with smaller footprint
- **Redis**: Fast caching with minimal resource usage
- **Monitoring Stack**: Efficient metrics collection and storage

<!--=====================================
=         CONSIDERATIONS              =
======================================-->
## Trade-offs and Considerations

While Alpine is excellent for our use case, it's important to note:

1. **Production Consideration**
   - Some teams prefer Debian for its familiarity
   - Larger community support for Debian-based solutions
   - More extensive documentation available

2. **Development Workflow**
   - Need to adapt to Alpine-specific commands
   - Different debugging tools and processes
   - Slightly different configuration paths

The choice of Alpine aligns perfectly with Inception's goals of understanding container infrastructure while maintaining efficient resource usage and security. 🎯

# Core Services: NGINX 🚀

<!--=====================================
=            INTRODUCTION             =
======================================-->

## What is NGINX? 🌐

NGINX (pronounced "engine-x") is a powerful, open-source software that functions as a web server, reverse proxy, load balancer, and HTTP cache. Originally designed to solve the C10K problem (handling 10,000 concurrent connections), NGINX has become one of the most popular web servers worldwide due to its efficiency and low resource consumption.

<!-- <ADD IMAGE: "Visual diagram showing NGINX's role as the single entry point, with TLS termination and request routing to various backend services. Include icons for SSL/TLS encryption, backend services, and traffic flow">

![NGINX Gateway](images/nginx-gateway.png) -->

<!--=====================================
=         CORE FUNCTIONALITY          =
======================================-->

## Why NGINX in Our Infrastructure? 🤔

In our Inception project, NGINX serves as the primary gateway to all our services:

1. **Single Entry Point** 🚪
   - All external traffic flows through NGINX
   - Centralized access control and monitoring
   - Simplified security management

2. **SSL/TLS Termination** 🔐
   - Handles all HTTPS encryption/decryption
   - Centralizes certificate management
   - Internal services communicate over unencrypted channels

3. **Reverse Proxy** 🔄
   - Routes requests to appropriate backend services
   - Hides internal infrastructure details
   - Provides URL path-based routing

## Security Benefits 🛡️

1. **TLS Communication**
   - Forces HTTPS for all connections
   - Implements modern TLS protocols (1.2 and 1.3)
   - Strong cipher suite configuration

2. **Network Isolation**
   - Backend services aren't directly exposed
   - Internal network segmentation
   - Minimized attack surface

## Performance Advantages ⚡

1. **Efficient Static File Serving**
   - Optimized for serving static content
   - Reduces load on application servers
   - Implements caching strategies

2. **Connection Handling**
   - Event-driven architecture
   - Excellent concurrent connection handling
   - Low memory footprint

## Service Integration Benefits 🔌

1. **WordPress Integration**
   - Serves static files directly
   - Routes PHP requests to PHP-FPM
   - Manages cache headers

2. **Monitoring Stack**
   - Routes to Prometheus/Grafana
   - URL path-based access
   - Consistent authentication

<!--=====================================
=     TECHNICAL IMPLEMENTATION        =
======================================-->

## Technical Implementation 🔧

### 1. Docker Compose Configuration

```yaml
nginx:
    container_name: nginx
    image: nginx
    build:
      context: ./requirements/nginx
      dockerfile: Dockerfile
    env_file:
      - .env
    ports:
      - "443:443"
    networks:
      - proxy
    depends_on:
      - mariadb
      - wordpress
      - ftp
      - redis
      - adminer
      - gatsby-app
      - alien-eggs
      - prometheus
      - grafana
      - cadvisor
    volumes:
      - wp-data:/var/www/html
    restart: on-failure
    healthcheck:
      test: ["CMD", "nginx", "-t"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
```

#### Key Elements Analysis:

1. **Volume Mount (`/var/www/html`)**:
   - Essential for serving WordPress files
   - The `wp-data` volume is shared between WordPress and NGINX
   - NGINX needs direct access to these files to serve static content efficiently
   - Without this mount, NGINX couldn't serve WordPress media or static assets

2. **Port 443**:
   - Only HTTPS port is exposed
   - No HTTP (port 80) access enforces secure connections
   - Internal service communication doesn't need port exposure
   - Maps container's internal port 443 to host's port 443

3. **Network Configuration**:
   - Connected only to `proxy` network
   - Isolates NGINX from database network
   - Enables communication with backend services
   - Follows principle of least privilege

<!--=====================================
=         DOCKERFILE SETUP            =
======================================-->

### 2. Dockerfile Analysis

```dockerfile
FROM alpine:3.19

RUN apk add --no-cache \
    nginx \
    openssl \
    apache2-utils \
    curl \
    shadow

RUN mkdir -p /var/www/html && \
    chown -R nginx:www-data /var/www/html

RUN usermod -aG www-data nginx

COPY --chown=nginx:nginx ./tools/init.sh /init.sh
RUN chmod +x /init.sh

ENTRYPOINT ["/init.sh"]
```

#### Package Analysis:

1. **Core Packages**:
   - `nginx`: Main web server package
   - `openssl`: Required for SSL certificate generation and management
   - `apache2-utils`: Provides useful tools like `htpasswd`
   - `curl`: Used for network testing and health checks
   - `shadow`: Required for user/group management

2. **Directory Setup**:
   - Creates `/var/www/html` directory
   - Sets ownership to nginx:www-data
   - Ensures proper permissions for file access

3. **User Configuration**:
   - Adds NGINX user to www-data group
   - Enables proper file access permissions
   - Follows security best practices

<!--=====================================
=       INITIALIZATION SCRIPT         =
======================================-->

### 3. Initialization Script Analysis 📝

1. **Initial Setup** (`set -e`):
   - Ensures script stops on any error
   - Critical for preventing partial configurations
   - Makes troubleshooting easier

2. **Directory Structure**:
   - `/etc/nginx/certs`: SSL certificate storage
   - `/var/log/nginx`: Log file location
   - `/var/www/html`: Web root directory
   - `/run/nginx`: Runtime files location

3. **SSL Certificate Generation**:
   - Checks for existing certificates
   - Generates self-signed certificate if needed
   - Uses environment variables for paths
   - Sets certificate details via `-subj` parameter

4. **Configuration File Generation**:
   - Creates main NGINX configuration
   - Uses heredoc for clean configuration writing
   - Environment variable substitution
   - Sets up all necessary server blocks

5. **Configuration Elements**:
   - SSL configuration
   - Server block setup
   - Proxy configurations
   - Location blocks for different services

6. **Error Handling**:
   - Built-in error checking
   - Clear error messages
   - Proper exit codes
   - Configuration validation