SHELL := /usr/bin/env bash

build_env:
	bin/build_env.sh

docker_config: build_env
	bin/build_env.sh && docker compose -f compose.dev config

images:
	docker compose -f compose.dev images

build: composer install_artisan_encryption_key npm_run_dev

docker_build:
	docker compose -f compose.dev.yaml build

composer:
	docker compose -f compose.dev.yaml exec workspace bash -c "composer install"

install_artisan_encryption_key:
	docker compose -f compose.dev.yaml exec workspace bash -c "php artisan key:generate"

npm_run_dev:
	docker compose -f compose.dev.yaml exec -it workspace bash -c "/usr/local/bin/npm install && /usr/local/bin/npm run dev"

bash:
	docker compose -f compose.dev.yaml exec workspace bash

up: build_env up_nobuild build

up_nobuild:
	docker compose -f compose.dev.yaml up -d --force-recreate --remove-orphans
	bin/wait_for_docker.bash "database system is ready to accept connections"

down:
	docker-compose down

down_ci:
	docker-compose -f compose.dev.yaml down || exit 0

#docker_clean_dangling_images_and_volumes:
docker_clean:
	docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
#docker volume rm $(docker volume ls -qf dangling=true)

logs_tail: build_env
	docker compose -f compose.dev.yaml logs -f
