### How to Run

It runs on Docker with Compose:

```
docker-compose up -d
docker-compose exec rake db:setup
docker-compose exec rake db:migrate
docker-compose exec rake db:seed
```

You can access http://localhost:3000

### Running Tests

```
docker-compose run -rm test
```
