COMPOSE_FOLDER = ./srcs
COMPOSE_FILE = $(COMPOSE_FOLDER)/docker-compose.yml

all: images start show

start:
	@echo "Starting containers..."
	@docker-compose -f $(COMPOSE_FILE) up -d --remove-orphans
	@echo "Containers started!"

show:
	@echo ============= Containers =============
	@docker ps -as
	@echo
	@echo ============= Network =============
	@docker network ls
	@echo
	@echo ============= Volumes =============
	@docker volume ls
	@echo

stop:
	@docker-compose -f $(COMPOSE_FILE) down -v --rmi all

down:
	@docker-compose -f $(COMPOSE_FILE) down

restart:
	@docker-compose -f $(COMPOSE_FILE) restart

re:
	@make prune
	@make all

prune:
	@echo "Deleting all..."
	@docker stop $$(docker ps -q)
	@docker rm $$(docker ps -a -q)
	@docker rmi -f $$(docker images -q)
	@docker volume rm $$(docker volume ls -q)
	@docker network rm $$(docker network ls -q)
	@docker image prune --all --force
	@docker system prune --all --force --volumes
	@echo "Done!"

images:
	@echo "Building images..."
	@docker-compose -f $(COMPOSE_FILE) build --parallel
	@echo "Images build done!"

setup_monitoring: generate_certs setup_grafana_dirs

generate_certs:
	@echo "Generating certificates for Prometheus..."
	@mkdir -p ./srcs/requirements/prometheus/certs
	@openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout ./srcs/requirements/prometheus/certs/prometheus.key \
		-out ./srcs/requirements/prometheus/certs/prometheus.crt \
		-subj "/C=IT/ST=Rome/L=Rome/O=42/OU=42/CN=prometheus.crea.42.fr"

setup_grafana_dirs:
	@echo "Setting up Grafana directories..."
	@mkdir -p ./srcs/requirements/grafana/dashboards
	@mkdir -p ./srcs/requirements/grafana/conf/provisioning/dashboards
	@mkdir -p ./srcs/requirements/grafana/conf/provisioning/datasources