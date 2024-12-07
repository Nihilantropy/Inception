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
