SHELL := /usr/bin/env bash

build_env:
	bin/build_env.sh

docker_config: build_env
	bin/build_env.sh && docker compose -f compose.dev config

images:
	docker compose -f compose.dev.yaml images

docker_build:
	docker compose -f compose.dev.yaml build

composer:
	docker compose -f compose.dev.yaml run --rm workspace bash -c "composer install"

install_artisan_encryption_key:
	docker compose -f compose.dev.yaml run --rm workspace bash -c "php artisan key:generate"

artisan_run_migrations:
	docker compose -f compose.dev.yaml exec workspace php artisan migrate

npm_run_dev:
	docker compose -f compose.dev.yaml exec -it workspace bash -c "/home/www/.nvm/versions/node/v22.0.0/bin/npm install && /home/www/.nvm/versions/node/v22.0.0/bin/npm run dev"

bash:
	docker compose -f compose.dev.yaml run --rm workspace bash

up: build_env composer up_nobuild artisan_run_migrations npm_run_dev

up_nobuild: install_artisan_encryption_key
	docker compose -f compose.dev.yaml up -d --force-recreate --remove-orphans
	bin/wait_for_docker.bash "database system is ready to accept connections"

down:
	docker compose -f compose.dev.yaml down

down_ci:
	docker compose -f compose.dev.yaml down || exit 0

#docker_clean_dangling_images_and_volumes:
docker_clean:
	docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
#docker volume rm $(docker volume ls -qf dangling=true)

logs_tail: build_env
	docker compose -f compose.dev.yaml logs -f
