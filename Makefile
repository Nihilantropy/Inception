COMPOSE_FOLDER = ./srcs
COMPOSE_FILE = $(COMPOSE_FOLDER)/docker-compose.yml
DATA_PATH = $(HOME)/data
FOLDER_PREFIX = srcs_

# List of Inception service names to identify related images
INCEPTION_SERVICES = nginx \
                    mariadb \
                    wordpress \
                    adminer \
                    redis \
                    ftp \
                    gatsby-app \
                    alien-eggs \
                    prometheus \
                    grafana

# List of Inception volumes and networks
INCEPTION_VOLUMES = $(FOLDER_PREFIX)wp-data \
                   $(FOLDER_PREFIX)db-data \
                   $(FOLDER_PREFIX)prometheus-data \
                   $(FOLDER_PREFIX)grafana-data
INCEPTION_NETWORKS = $(FOLDER_PREFIX)backend-db \
                    $(FOLDER_PREFIX)proxy \
                    $(FOLDER_PREFIX)monitoring

all: setup images start show art

setup: setup_volumes

setup_volumes:
	@echo "Creating data directories..."
	@mkdir -p $(DATA_PATH)/wordpress
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/prometheus
	@mkdir -p $(DATA_PATH)/grafana
	@echo "Data directories created!"

images:
	@echo "Building images..."
	@docker-compose -f $(COMPOSE_FILE) build --parallel
	@echo "Images build done!"

start:
	@echo "Starting containers..."
	@docker-compose -f $(COMPOSE_FILE) up -d
	@echo "Containers started!"

show:
	@echo ============= Containers =============
	@docker ps -a
	@echo
	@echo ============= Networks =============
	@docker network ls --filter name="$(FOLDER_PREFIX)"
	@echo
	@echo ============= Volumes =============
	@docker volume ls --filter name=$(FOLDER_PREFIX)
	@echo

stop:
	@docker-compose -f $(COMPOSE_FILE) down -v --rmi all

down:
	@docker-compose -f $(COMPOSE_FILE) down

restart:
	@docker-compose -f $(COMPOSE_FILE) restart

re: prune all

prune:
	@echo "Deleting all Inception-related resources..."
	@echo "Stopping containers..."
	@docker-compose -f $(COMPOSE_FILE) down -v 2>/dev/null || true
	@echo "Removing Inception containers..."
	@for service in $(INCEPTION_SERVICES); do \
		docker rm -f $$service 2>/dev/null || true; \
	done
	@echo "Removing Inception images..."
	@for service in $(INCEPTION_SERVICES); do \
		docker rmi -f $$service 2>/dev/null || true; \
	done
	@echo "Removing Inception volumes..."
	@for volume in $(INCEPTION_VOLUMES); do \
		docker volume rm $$volume 2>/dev/null || true; \
	done
	@echo "Removing Inception networks..."
	@for network in $(INCEPTION_NETWORKS); do \
		docker network rm $$network 2>/dev/null || true; \
	done
	@echo "Removing data directories..."
	@rm -rf $(DATA_PATH)/* 2>/dev/null || true
	@echo "Done! All Inception-related resources have been removed."

art:
	@echo	"\n"	
	@echo	"░▒▓█▓▒░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓████████▓▒░▒▓███████▓▒░▒▓████████▓▒░▒▓█▓▒░░▒▓██████▓▒░░▒▓███████▓▒░"  
	@echo	"░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░   ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░" 
	@echo	"░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░   ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░" 
	@echo	"░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓██████▓▒░ ░▒▓███████▓▒░  ░▒▓█▓▒░   ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░" 
	@echo	"░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░        ░▒▓█▓▒░   ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░" 
	@echo	"░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░        ░▒▓█▓▒░   ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░" 
	@echo	"░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓████████▓▒░▒▓█▓▒░        ░▒▓█▓▒░   ░▒▓█▓▒░░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░" 
	@echo	"\n"
																											
                                                                                                        


.PHONY: all setup setup_volumes setup_docker_volumes setup_monitoring generate_certs setup_grafana_dirs images start show stop down restart re prune