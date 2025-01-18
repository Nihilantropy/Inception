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

### Take a look :mag:!

```Bash
cat /srcs/requirements/nginx/tools/init.sh
```

# Core Services: WordPress 🎨

<!--=====================================
=            INTRODUCTION             =
======================================-->

## What is WordPress? 📝

WordPress is the world's most popular content management system (CMS), powering over 40% of all websites. In our Inception infrastructure, WordPress runs with PHP-FPM (FastCGI Process Manager) for optimal performance and resource utilization. This setup separates the PHP processing from the web server, allowing for better scaling and resource management.

<!--=====================================
=         CORE FUNCTIONALITY          =
======================================-->

## Why WordPress + PHP-FPM? 🤔

Our WordPress implementation focuses on three key aspects:

1. **Performance Optimization** ⚡
   - PHP-FPM process management
   - Redis cache integration
   - Optimized PHP configuration

2. **Security Hardening** 🛡️
   - Custom user configuration
   - File permission management
   - Secure WordPress settings

3. **Integration** 🔌
   - MariaDB database connection
   - Redis cache coordination
   - NGINX communication
   - FTP service coordination

## Architecture Benefits 🏗️

1. **FastCGI Processing**
   - Separate PHP process management
   - Dynamic process scaling
   - Efficient resource utilization

2. **File System Organization**
   - Structured content storage
   - Shared volume management
   - Proper permissions hierarchy

3. **Cache Integration**
   - Redis object caching
   - Session handling
   - Persistent cache storage

<!--=====================================
=     TECHNICAL IMPLEMENTATION        =
======================================-->

## Technical Implementation 🔧

### 1. Docker Compose Configuration

```yaml
wordpress:
    container_name: wordpress
    image: wordpress
    env_file:
      - .env
    build:
      context: ./requirements/wordpress
      dockerfile: Dockerfile
    volumes:
      - wp-data:/var/www/html
    networks:
      - backend-db
      - proxy
      - cache
    depends_on:
      - mariadb
    restart: on-failure
    healthcheck:
      test: ["CMD", "php-fpm81", "-t"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
```

#### Key Elements Analysis:

1. **Volume Configuration**:
   - `wp-data` volume stores WordPress files
   - Shared with `NGINX`, `FTP` and `REDIS` for file access
   - Persists through container restarts
   - Maintains proper file permissions

2. **Network Setup**:
   - Connected to `backend-db`, `proxy` and `cache` networks
   - Enables database and cache access
   - Allows NGINX communication
   - Maintains network isolation

3. **Dependencies**:
   - Requires MariaDB for database
   - Ensures proper startup order
   - Maintains service availability

<!--=====================================
=         DOCKERFILE SETUP            =
======================================-->

### 2. Dockerfile Analysis

```dockerfile
FROM alpine:3.19

RUN apk update && apk add --no-cache \
    php81 \
    php81-fpm \
    php81-mysqli \
    php81-curl \
    php81-json \
    php81-zip \
    php81-gd \
    php81-mbstring \
    php81-xml \
    php81-session \
    php81-opcache \
    php81-phar \
    php81-pecl-redis \
    php81-ctype \
    php81-ftp \
    mariadb-client \
    curl \
    bash

RUN adduser -S -G www-data www-data

COPY ./tools/init-wp-config.sh /usr/local/bin/
COPY ./tools/init-wordpress.sh /usr/local/bin/
COPY ./tools/setup_db.sh /usr/local/bin/
COPY ./tools/test_ftp.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/init-wp-config.sh && \
    chmod +x /usr/local/bin/init-wordpress.sh && \
    chmod +x /usr/local/bin/setup_db.sh && \
    chmod +x /usr/local/bin/test_ftp.sh
```

#### Package Analysis:

1. **PHP Core & Extensions**:
   - `php81-fpm`: FastCGI Process Manager
   - `php81-mysqli`: MySQL database support
   - `php81-pecl-redis`: Redis integration
   - `php81-ftp`: FTP integration
   - Various required PHP extensions

2. **Additional Tools**:
   - `mariadb-client`: Database management
   - `curl`: Network operations
   - `bash`: Script execution

3. **User & Permission Management**:
   - Creates www-data user and group
   - Critical for secure file operations
   - Enables proper service coordination

   The www-data user is crucial in our setup:
   - **Security**: Provides a non-root user for running PHP-FPM processes
   - **File Access**: Coordinates file permissions between NGINX, WordPress, and FTP
   - **Process Isolation**: Ensures PHP processes run with minimal privileges
   - **Service Coordination**: Enables seamless operation between NGINX, PHP-FPM, WordPress, and FTP
   - **Shared Ownership**: Manages shared volume access across containers
   - **FTP Integration**: Ensures FTP users can properly interact with WordPress files
   
   The www-data group is particularly important for FTP operations:
   - FTP users are added to the www-data group
   - Enables proper file modifications through FTP
   - Maintains correct permissions for WordPress operations
   - Allows secure file uploads via FTP
   - Prevents permission conflicts between services

<!--=====================================
=     INITIALIZATION PROCESS          =
======================================-->

### 3. WordPress Initialization 🔄

The initialization process follows a structured approach:

1. **Configuration Setup** (`init-wp-config.sh`):
   - WordPress configuration file creation
   - Database connection setup
   - Redis cache configuration
   - FTP server configuration
   - Security keys generation

2. **WordPress Core** (`init-wordpress.sh`):
   - Core files installation
   - Initial site setup
   - User creation
   - Plugin activation

3. **Database Integration** (`setup_db.sh`):
   - Database connection verification
   - Table creation/verification
   - Initial data population
   - User permissions setup

### 4. Key Configuration Elements 🎛️

1. **custom wp-config**
init-wp-config.sh script create a custom `wp-config.php` file,
tailored around our needs.
Using the `cat` command ensure proper ENV `var expansion`.

2. **PHP-FPM Settings**:
`Point 9` of the `init-wordpress.sh` script ensure proper `php-fpm` setup
by changing the default `user`, `group` and `listen` interface to our needs

```Bash
sed -i -r 's|^user = .*$|user = www-data|' /etc/php81/php-fpm.d/www.conf
sed -i -r 's|^group = .*$|group = www-data|' /etc/php81/php-fpm.d/www.conf
sed -i -r 's|listen = 127.0.0.1:9000|listen = 0.0.0.0:9000|' /etc/php81/php-fpm.d/www.conf
```

<!--=====================================
=         SECURITY MEASURES           =
======================================-->

## Security Implementation 🔒

1. **File Permissions and www-data Role**:
   - WordPress files: 644 (owned by www-data:www-data)
   - Directories: 755 (owned by www-data:www-data)
   - Sensitive files: 600 (owned by www-data:www-data)
   - wp-content: 775 (allows runtime modifications)

   The www-data ownership is essential because:
   - NGINX worker processes run as www-data
   - PHP-FPM processes run as www-data
   - WordPress needs to write to wp-content
   - Ensures proper file access between services
   - Prevents permission-related errors during plugin/theme installations

2. **Database Security**:
   - Separate user accounts
   - Limited privileges
   - Prepared statements
   - Secure connections

3. **WordPress Hardening**:
   - Custom table prefix
   - Disabled file editing
   - Secure authentication keys
   - Limited login attempts

<!--=====================================
=         PERFORMANCE TUNING          =
======================================-->

## Performance Optimization ⚡

1. **Redis Integration**:
   - Redis plugin installation and configuration in init-wordpress.sh:
     ```bash
     wp plugin install redis-cache --activate
     cp wp-content/plugins/redis-cache/includes/object-cache.php wp-content/object-cache.php
     wp redis enable
     ```
   - Redis configuration in wp-config.php:
     ```php
     define( 'WP_REDIS_HOST', '${REDIS_HOST}' );
     define( 'WP_REDIS_PORT', ${REDIS_PORT} );
     define('WP_CACHE', true);
     define('WP_REDIS_DISABLE_METRICS', false);
     define('WP_REDIS_METRICS_MAX_TIME', 60);
     define('WP_REDIS_SELECTIVE_FLUSH', true);
     define('WP_REDIS_MAXTTL', 86400);
     ```

2. **Database Setup & Optimization**:
   - Database initialization in setup_db.sh:
     - Properly structured users table creation
     - Default user setup
     - Connection verification
   - MariaDB connection configuration in wp-config.php:
     ```php
     define('DB_HOST', '${MYSQL_HOST}');
     define('DB_CHARSET', 'utf8');
     define('DB_COLLATE', '');
     ```
   - Connection retry mechanism in scripts

### Take a look :mag:!

```Bash
cat /srcs/requirements/wordpress/tools/init-wordpress.sh
```
```Bash
cat /srcs/requirements/wordpress/tools/init-wp-config.sh
```
```Bash
cat /srcs/requirements/wordpress/tools/setup_db.sh
```

This WordPress setup provides a robust, secure, and performant foundation for our web application, integrated seamlessly with other services in our infrastructure. 🚀

# Core Services: MariaDB 🗄️

<!--=====================================
=            INTRODUCTION             =
======================================-->

## What is MariaDB? 📊

MariaDB is a community-developed, commercially supported fork of MySQL that provides a robust, scalable, and reliable SQL server. In our Inception infrastructure, MariaDB serves as the primary database system, handling data persistence for WordPress and providing secure, efficient data storage and retrieval capabilities.

<!--=====================================
=         CORE FUNCTIONALITY          =
======================================-->

## Why MariaDB in Our Infrastructure? 🤔

Our MariaDB implementation focuses on three key aspects:

1. **Data Persistence** 💾
   - Reliable storage for WordPress data
   - Transaction management
   - Data integrity maintenance

2. **Performance Optimization** ⚡
   - Efficient query processing
   - Memory management
   - Connection pooling

3. **Security Hardening** 🛡️
   - User authentication
   - Access control
   - Network isolation

## Architecture Benefits 🏗️

1. **Database Management**
   - Structured data organization
   - ACID compliance
   - Backup capabilities

2. **Resource Efficiency**
   - Optimized memory usage
   - Connection pooling
   - Query caching

3. **Security Features**
   - Authentication mechanisms
   - Network-level security
   - Data encryption support

<!--=====================================
=     TECHNICAL IMPLEMENTATION        =
======================================-->

## Technical Implementation 🔧

### 1. Docker Compose Configuration

```yaml
mariadb:
    container_name: mariadb
    image: mariadb
    build:
      context: ./requirements/mariadb
    env_file:
      - .env
    volumes:
      - db-data:/var/lib/mysql
    networks:
      - backend-db
    restart: on-failure
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p${MYSQL_ROOT_PASSWORD}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
```

#### Key Elements Analysis:

1. **Volume Configuration**:
   - `db-data` volume persists database files
   - Mounted at `/var/lib/mysql`
   - Survives container restarts
   - Ensures data durability

2. **Network Setup**:
   - Connected only to `backend-db` network
   - Isolated from public access
   - Direct access only from `WordPress` and `Adminer`
   - Enhanced security through network segregation

3. **Health Monitoring**:
   - Regular ping checks
   - Fast failure detection
   - Automatic recovery
   - Proper startup delay

<!--=====================================
=         DOCKERFILE SETUP            =
======================================-->

### 2. Dockerfile Analysis

```dockerfile
FROM alpine:3.19

ENV MARIADB_DATA_DIR=/var/lib/mysql

RUN apk update && apk add --no-cache \
    mariadb mariadb-client && \
    mkdir -p "$MARIADB_DATA_DIR" && \
    chown -R mysql:mysql "$MARIADB_DATA_DIR" && \
    mysql_install_db --user=mysql --datadir="$MARIADB_DATA_DIR"

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

COPY ./conf/my.cnf /etc/my.cnf
COPY ./tools/init.sh /docker-entrypoint-initdb.d/init.sh
RUN chmod +x /docker-entrypoint-initdb.d/init.sh

EXPOSE 3306

CMD ["/docker-entrypoint-initdb.d/init.sh"]
```

#### Package Analysis:

1. **Core Components**:
   - `mariadb`: Main database server
   - `mariadb-client`: Command-line tools
   - Essential system utilities

2. **Directory Setup**:
   - Creates data directory
   - Sets proper ownership
   - Initializes database files

3. **Configuration**:
   - Custom my.cnf file
   - Initialization script
   - Runtime directory setup

<!--=====================================
=       CONFIGURATION ANALYSIS        =
======================================-->

### 3. MariaDB Configuration

The `my.cnf` file contains essential MariaDB settings:

```ini
[mysqld]
bind-address = 0.0.0.0
port = 3306
datadir = /var/lib/mysql
socket = /run/mysqld/mysqld.sock

# Recommended settings for WordPress
character-set-server = utf8mb4
collation-server = utf8mb4_general_ci

# Performance tuning
max_connections = 150
innodb_buffer_pool_size = 128M

[client]
default-character-set = utf8mb4
socket = /run/mysqld/mysqld.sock
```

#### Configuration Elements:

1. **Network Settings**:
   - Listens on all interfaces
   - Standard port 3306
   - Socket configuration

2. **Character Encoding**:
   - UTF8MB4 for full Unicode support
   - WordPress-optimized collation
   - Consistent encoding across connections

3. **Performance Settings**:
   - Connection limit
   - Buffer pool size
   - Memory optimization

<!--=====================================
=     INITIALIZATION PROCESS          =
======================================-->

### 4. Database Initialization

The initialization script (`init.sh`) handles database setup:

```bash
#!/bin/sh

# Generate initialization SQL file
cat << EOF > /docker-entrypoint-initdb.d/init.sql
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF

# Start MariaDB with initialization
exec mysqld --datadir="$MARIADB_DATA_DIR" --user=mysql --init-file=/docker-entrypoint-initdb.d/init.sql
```

#### Process Breakdown:

1. **Database Creation**:
   - Creates WordPress database
   - Uses environment variables
   - Handles existing database gracefully

2. **User Management**:
   - Creates application user
   - Sets secure password
   - Grants appropriate privileges

3. **Security Setup**:
   - Limited user privileges
   - Secure password handling
   - Proper permission configuration

<!--=====================================
=         SECURITY MEASURES           =
======================================-->

## Security Implementation 🔒

1. **Access Control**:
   - User-based authentication
   - Role-based privileges
   - Network-level restrictions

2. **Data Protection**:
   - File system permissions
   - Network isolation
   - Secure configuration

3. **Network Security**:
   - Backend network isolation
   - No public exposure
   - Limited connection access

<!--=====================================
=         PERFORMANCE TUNING          =
======================================-->

## Performance Optimization ⚡

1. **Buffer Configuration**:
   - Optimized buffer pool size
   - Query cache settings
   - Connection pool management

2. **Character Set Optimization**:
   - UTF8MB4 encoding
   - Proper collation
   - Index optimization

3. **Connection Management**:
   - Limited max connections
   - Connection timeout settings
   - Thread handling optimization

### Take a look :mag:!

```Bash
cat /srcs/requirements/mariadb/tools/init.sh
```

This MariaDB setup provides a secure, efficient, and reliable database backend for our WordPress installation, ensuring data persistence and optimal performance. 🚀

# Bonus Services: Adminer 🎛️

<!--=====================================
=            INTRODUCTION             =
======================================-->

## What is Adminer? 📊

Adminer (formerly phpMyAdmin) is a full-featured database management tool written in PHP. In our Inception infrastructure, Adminer provides a lightweight, secure web interface for managing the MariaDB database, offering a user-friendly alternative to command-line database administration.

<!--=====================================
=         CORE FUNCTIONALITY          =
======================================-->

## Why Adminer in Our Infrastructure? 🤔

Our Adminer implementation focuses on three key aspects:

1. **Database Management** 💾
   - Visual database interface
   - Query execution
   - Database structure manipulation
   - Data import/export capabilities

2. **Security Implementation** 🛡️
   - Secure authentication
   - Access control
   - HTTPS encryption (via NGINX)
   - Network isolation

3. **Integration** 🔌
   - MariaDB connectivity
   - NGINX reverse proxy
   - PHP-FPM processing
   - Connection pooling

## Architecture Benefits 🏗️

1. **Lightweight Solution**
   - Single PHP file
   - Minimal dependencies
   - Efficient resource usage
   - Fast page loads

2. **Security Features**
   - No stored credentials
   - Session-based authentication
   - SQL injection prevention
   - XSS protection

3. **User Interface**
   - Intuitive design
   - Responsive layout
   - Modern features
   - Dark mode support

<!--=====================================
=     TECHNICAL IMPLEMENTATION        =
======================================-->

## Technical Implementation 🔧

### 1. Docker Compose Configuration

```yaml
adminer:
    container_name: adminer
    image: adminer
    build:
      context: ./requirements/bonus/adminer
      dockerfile: Dockerfile
    env_file:
      - .env
    networks:
      - backend-db
      - proxy
    restart: on-failure
    depends_on:
      - mariadb
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--spider", "http://localhost:8080/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
```

#### Key Elements Analysis:

1. **Network Configuration**:
   - Connected to `backend-db` for database access
   - Connected to `proxy` for NGINX communication
   - Isolated from other services
   - Secure network segmentation

2. **Health Monitoring**:
   - Regular health checks
   - Quick failure detection
   - Automatic recovery
   - Proper startup delay

3. **Dependencies**:
   - Requires MariaDB service
   - Ensures proper startup order
   - Maintains service availability

<!--=====================================
=         DOCKERFILE SETUP            =
======================================-->

### 2. Dockerfile Analysis

```dockerfile
FROM alpine:3.19

RUN apk update && apk add --no-cache \
    apache2 \
    php81 \
    php81-apache2 \
    php81-curl \
    php81-cli \
    php81-mysqli \
    php81-gd \
    php81-session \
    php81-pdo \
    php81-pdo_mysql \
    php81-json \
    php81-mbstring \
    mariadb-client \
    wget

RUN addgroup -S -g 82 www-data 2>/dev/null || true && \
    adduser -S -u 82 -D -H -h /var/www -G www-data -g www-data www-data 2>/dev/null || true

RUN mkdir -p /var/www/html \
    && mkdir -p /run/apache2

COPY tools/init.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init.sh

EXPOSE 8080

CMD ["/usr/local/bin/init.sh"]
```

#### Package Analysis:

1. **Core Components**:
   - `apache2`: Web server
   - `php81`: PHP runtime
   - Various PHP extensions for functionality
   - `mariadb-client`: Database connectivity

2. **PHP Extensions**:
   - `php81-mysqli`: MySQL/MariaDB support
   - `php81-pdo`: Database abstraction
   - `php81-session`: Session management
   - `php81-json`: JSON processing

3. **Security Setup**:
   - Creates www-data user/group
   - Sets proper permissions
   - Configures runtime directories

<!--=====================================
=     INITIALIZATION PROCESS          =
======================================-->

### 3. Initialization Script Analysis

The initialization script (`init.sh`) handles the setup and configuration:

```bash
#!/bin/sh
set -e

echo "=== Starting Adminer Initialization ==="

echo "1. Setting up Adminer..."
if [ ! -f "/var/www/html/index.php" ]; then
    echo "- Downloading latest version of Adminer..."
    cd /var/www/html
    if wget "http://www.adminer.org/latest.php" -O index.php; then
        echo "- Setting proper ownership..."
        chown -R www-data:www-data /var/www/html
        echo "- Setting file permissions..."
        chmod 775 index.php
        echo "✅ Adminer downloaded and configured successfully"
    else
        echo "❌ ERROR: Failed to download Adminer!"
        exit 1
    fi
fi

echo "2. Configuring Apache server..."
echo "ServerName localhost" >> /etc/apache2/httpd.conf

echo "3. Creating virtual host configuration..."
cat > /etc/apache2/conf.d/adminer.conf << 'EOF'
<VirtualHost *:8080>
    ServerName localhost
    DocumentRoot /var/www/html
    DirectoryIndex index.php
    
    <Directory /var/www/html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
        
        # Redirect /adminer.php to index.php for healthcheck
        RedirectMatch 301 ^/adminer\.php$ /
    </Directory>

    ErrorLog /dev/stderr
    CustomLog /dev/stdout combined
</VirtualHost>
EOF

echo "4. Configuring Apache modules and settings..."
sed -i \
    -e 's/#LoadModule rewrite_module/LoadModule rewrite_module/' \
    -e 's/Listen 80/Listen 8080/' \
    -e 's/User apache/User www-data/' \
    -e 's/Group apache/Group www-data/' \
    /etc/apache2/httpd.conf

echo "5. Configuring PHP..."
sed -i \
    -e 's/;extension=pdo_mysql/extension=pdo_mysql/' \
    -e 's/;extension=mysqli/extension=mysqli/' \
    /etc/php81/php.ini

echo "6. Setting up permissions..."
chown -R www-data:www-data /run/apache2 /var/www/html /var/log/apache2

echo "7. Creating healthcheck symlink..."
ln -sf /var/www/html/index.php /var/www/html/adminer.php

# Start Apache in foreground
exec httpd -D FOREGROUND
```

#### Process Breakdown:

1. **Adminer Installation**:
   - Downloads latest version
   - Sets proper ownership
   - Configures permissions
   - Creates required directories

2. **Apache Configuration**:
   - Sets up virtual host
   - Configures modules
   - Sets security options
   - Enables PHP processing

3. **PHP Setup**:
   - Enables required extensions
   - Configures PHP settings
   - Sets up error logging
   - Optimizes performance

<!--=====================================
=         SECURITY MEASURES           =
======================================-->

## Security Implementation 🔒

1. **Access Control**:
   - Database credentials protection
   - Session-based authentication
   - HTTPS encryption (via NGINX)
   - IP-based access control

2. **File System Security**:
   - Proper file permissions
   - Secure ownership
   - Directory access control
   - Temporary file management

3. **Network Security**:
   - Backend network isolation
   - Proxy through NGINX
   - Limited port exposure
   - Secure connection handling

<!--=====================================
=         PERFORMANCE TUNING          =
======================================-->

## Performance Optimization ⚡

1. **Apache Configuration**:
   - Module optimization
   - Worker process tuning
   - Connection pooling
   - Keep-alive settings

2. **PHP Settings**:
   - Opcode caching
   - Memory limits
   - Session handling
   - Error reporting

3. **Resource Management**:
   - Minimal dependencies
   - Efficient file serving
   - Query optimization
   - Cache utilization

### Take a look 🔍!

```bash
cat /srcs/requirements/bonus/adminer/tools/init.sh
```

This Adminer setup provides a secure, efficient, and user-friendly interface for database management in our infrastructure. The implementation prioritizes security while maintaining ease of use and performance. 🚀

# Bonus Services: Redis ⚡

<!--=====================================
=            INTRODUCTION             =
======================================-->

## What is Redis? 🚀

Redis (Remote Dictionary Server) is an open-source, in-memory data structure store used as a database, cache, message broker, and queue. In our Inception infrastructure, Redis serves as a high-performance caching layer for WordPress, significantly improving response times and reducing database load.

<!--=====================================
=         CORE FUNCTIONALITY          =
======================================-->

## Why Redis in Our Infrastructure? 🤔

Our Redis implementation focuses on these key aspects:

1. **Performance Enhancement** 💨
   - In-memory data storage
   - WordPress object caching
   - Session management
   - Page caching acceleration

2. **Resource Optimization** 🎯
   - Database load reduction
   - Memory management with LRU eviction
   - Connection pooling
   - Efficient cache invalidation

3. **WordPress Integration** 🔌
   - Object caching via Redis plugin
   - PHP extension support
   - Coordinated cache management
   - Transient and fragment caching

<!--=====================================
=     TECHNICAL IMPLEMENTATION        =
======================================-->

## Technical Implementation 🔧

### 1. Docker Compose Configuration

```yaml
redis:
    container_name: redis
    image: redis
    build:
      context: ./requirements/bonus/redis
      dockerfile: Dockerfile
    volumes:
      - wp-data:/var/www/html
    networks:
      - cache
    restart: on-failure
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
```

#### Key Elements:

- Shares WordPress volume for data persistence
- Isolated in dedicated `cache` network
- Regular health monitoring via Redis CLI
- Automatic failure recovery

### 2. Dockerfile Analysis

```dockerfile
FROM alpine:3.19

RUN apk update && apk add --no-cache redis && \
    echo "maxmemory 256mb" >> /etc/redis.conf && \
    echo "maxmemory-policy allkeys-lru" >> /etc/redis.conf && \
    sed -i 's/^bind 127.0.0.1/#bind 127.0.0.1/' /etc/redis.conf && \
    mkdir -p /data && chown redis:redis /data

EXPOSE 6379

CMD ["redis-server", "/etc/redis.conf", "--protected-mode", "no"]
```

#### Configuration Elements:
- Memory limit: 256MB with LRU eviction
- Remote connections enabled
- Dedicated data directory with proper permissions
- Protected mode disabled for container environment

<!--=====================================
=     WORDPRESS INTEGRATION          =
======================================-->

### 3. WordPress Integration

Redis configuration in wp-config.php:

```php
/* Redis configuration */
define('WP_REDIS_HOST', '${REDIS_HOST}');
define('WP_REDIS_PORT', ${REDIS_PORT});
define('WP_REDIS_TIMEOUT', 1);
define('WP_REDIS_READ_TIMEOUT', 1);
define('WP_REDIS_DATABASE', 0);
define('WP_CACHE', true);

define('WP_REDIS_DISABLE_METRICS', false);
define('WP_REDIS_METRICS_MAX_TIME', 60);
define('WP_REDIS_SELECTIVE_FLUSH', true);
define('WP_REDIS_MAXTTL', 86400);
```

Key settings:
- Host and port configuration
- Timeout management
- Metrics collection enabled
- Selective cache flushing
- 24-hour maximum TTL

<!--=====================================
=     SECURITY & PERFORMANCE          =
======================================-->

## Security and Performance 🛡️

### Security Measures:
- Network isolation through Docker networks
- Volume permissions and ownership
- Memory limits prevent resource exhaustion
- Internal-only network exposure

### Performance Optimization:
- Fixed memory limit with LRU eviction
- Optimized connection handling
- Selective cache invalidation
- Efficient key storage and expiration

This Redis implementation provides a robust caching solution for WordPress, balancing performance, security, and reliability. 🚀

# Bonus Services: FTP 📂

<!--=====================================
=            INTRODUCTION             =
======================================-->

## What is VSFTPD? 🚀

VSFTPD (Very Secure FTP Daemon) is a secure and stable FTP server. In our Inception infrastructure, it provides file transfer capabilities for WordPress, enabling secure file uploads and management through FTP protocol while maintaining proper permissions and security.

<!--=====================================
=         CORE FUNCTIONALITY          =
======================================-->

## Why VSFTPD in Our Infrastructure? 🤔

Our FTP implementation focuses on these key aspects:

1. **File Management** 📁
   - file transfers
   - WordPress uploads handling
   - Permission management
   - User authentication

2. **Security** 🛡️
   - Chroot environment
   - User isolation
   - Permission controls
   - SSL/TLS support (not implemented)

3. **WordPress Integration** 🔌
   - Direct access to WordPress files
   - Plugin and theme management
   - Media upload support
   - Proper ownership coordination

<!--=====================================
=     TECHNICAL IMPLEMENTATION        =
======================================-->

## Technical Implementation 🔧

### 1. Docker Compose Configuration

```yaml
ftp:
    container_name: ftp
    image: ftp
    build:
      context: ./requirements/bonus/ftp
      dockerfile: Dockerfile
    env_file:
      - .env
    ports:
      - "20:20"
      - "21:21"
      - "21100-21110:21100-21110"
    volumes:
      - wp-data:/var/www/html
    networks:
      - proxy
    restart: on-failure
    healthcheck:
      test: ["CMD", "netstat", "-ln", "|", "grep", ":21"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
```

#### Key Elements:
- Exposes FTP control (21) and data (20) ports
- Passive port range (21100-21110)
- Shares WordPress volume
- Network isolation via proxy network
- Regular health monitoring

### 2. Dockerfile Analysis

```dockerfile
FROM alpine:3.19

RUN apk update && \
    apk add --no-cache \
        vsftpd \
        shadow \
        linux-pam \
        bash \
        netcat-openbsd \
        logrotate

RUN mkdir -p /var/log && \
    mkdir -p /etc/vsftpd && \
    mkdir -p /var/run/vsftpd

COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

WORKDIR /var/www/html

EXPOSE 20 21 21100-21110

ENTRYPOINT ["/usr/local/bin/init.sh"]
```

#### Configuration Elements:
- VSFTPD installation with dependencies
- Log management with logrotate
- Working directory set to WordPress root
- Initialization script for setup
- Port exposure for FTP service

### 3. VSFTPD Configuration

The initialization script generates vsftpd.conf:

```ini
# Standalone mode
listen=YES
listen_port=21
listen_address=0.0.0.0
background=NO
max_clients=10

# Access Control
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022

# Security
chroot_local_user=YES
allow_writeable_chroot=YES
hide_ids=YES
dirlist_enable=YES
download_enable=YES

# Local User Config
user_sub_token=$USER
local_root=/var/www/html
guest_enable=NO
virtual_use_local_privs=YES

# Logging
xferlog_enable=YES
xferlog_file=/var/log/vsftpd.log
log_ftp_protocol=YES
debug_ssl=YES

# Passive Mode Config
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110
pasv_address=0.0.0.0

# Timeout Config
idle_session_timeout=300
data_connection_timeout=300
accept_timeout=60
connect_timeout=60

# System Settings
seccomp_sandbox=NO
ascii_upload_enable=YES
ascii_download_enable=YES
```

### 4. User and Permission Management

The initialization script handles user setup:

```bash
# User creation and configuration
FTP_USER=${FTP_USER:-ftpuser}
adduser -D -h /var/www/html -s /bin/ash "${FTP_USER}"
adduser "${FTP_USER}" www-data
echo "${FTP_USER}:${FTP_PASS}" | chpasswd

# Directory permissions
chown -R ${FTP_USER}:www-data /var/www/html
chmod -R 775 /var/www/html
usermod -aG www-data $FTP_USER
```

Key aspects:
- Creates FTP user with environment variables
- Adds user to www-data group
- Sets proper WordPress directory permissions
- Ensures coordinated access with NGINX and PHP

<!--=====================================
=     SECURITY & PERFORMANCE          =
======================================-->

## Security and Performance 🔒

### Security Measures:
- User chroot jail
- No anonymous access
- Secure password handling
- Limited passive port range
- Proper file permissions
- Log rotation setup
- PAM authentication

### WordPress Integration:
- Direct access to WordPress files
- Coordinated permissions with PHP-FPM
- Plugin/theme upload support
- Secure file transfer
- Proper ownership maintenance

### Additional Features:
- Passive mode support for NAT/firewall compatibility
- Log rotation for maintenance
- Health monitoring
- Automatic recovery
- Session timeout management

This FTP implementation provides secure file transfer capabilities while maintaining proper integration with WordPress and other services in our infrastructure. 🚀