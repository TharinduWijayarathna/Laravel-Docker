.PHONY: clear

up:
	@if [ ! -f .env ]; then \
		echo "An .env file was not found! Please create a .env file before proceeding." && exit 1; \
	fi

	docker compose up --build -d --remove-orphans
	@make check-url
	@echo "Docker Compose services are up and running successfully!"

check-url:
	until [ "$$(docker compose exec -it laravel curl -s -o /dev/null -w "%{http_code}" http://localhost)" -eq "200" ]; do \
		echo "Waiting for server to be ready..."; \
		sleep 5; \
	done;
	@echo "Success: Server is up and running."

clear:
	@echo "Clearing cache..."
	@php artisan cache:clear
	@echo "Clearing routes..."
	@php artisan route:clear
	@echo "Clearing config..."
	@php artisan config:clear
	@echo "All clear!"

ssh-web:
	@docker compose exec -it laravel bash

mysql:
	@docker compose exec -it mysql mysql -uroot -ppassword patpat

test:
	@docker compose exec -it laravel php artisan test

refresh-db:
	@echo "Refreshing the DB..."
	@docker compose exec -it laravel php artisan migrate:fresh
	@docker compose exec -it laravel php artisan db:seed

refresh-testing-db:
	@echo "Refreshing the DB..."
	@docker compose exec -it mysql mysql -uroot -ppassword -e "DROP DATABASE IF EXISTS patpat_testing; CREATE DATABASE patpat_testing;"
	@docker compose exec -it mysql mysql -uroot -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO 'sail'@'%' WITH GRANT OPTION;"
	@docker compose exec -it laravel php artisan migrate --env=testing
	@docker compose exec -it laravel php artisan db:seed --env=testing

down:
	docker compose down --volumes
