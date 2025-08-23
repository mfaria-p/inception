name = inception

all:
	@printf "Running the configuration ${name}...\n"
	@docker-compose -f srcs/docker-compose.yml up -d

build:
	@printf "Assembling the configuration ${name}...\n"
	@docker-compose -f srcs/docker-compose.yml up -d --build

down:
	@printf "Stopping the configuration ${name}...\n"
	@docker-compose -f srcs/docker-compose.yml down

re:
	@printf "Rebuilding the configuration ${name}...\n"
	@docker-compose -f srcs/docker-compose.yml up -d --build

clean: down
	@printf "Cleaning the configuration ${name}...\n"
	@docker system prune -a

fclean:
	@printf "Complete cleanup of all docker configurations...\n"
	@docker stop $$(docker ps -qa)
	@docker system prune --all --force --volumes
	@docker network prune --force
	@docker volume prune --force

.PHONY: all build down re clean clean
