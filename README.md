# How to Even Run Rails on Docker on Mac

Combined with input from:

- https://docs.docker.com/machine/get-started/
- http://docs.docker.com/compose/rails/
- https://www.youtube.com/watch?v=CVO_imNSw2o

This assumes you already have a working Rails application that's

- Install [Docker Toolbox](https://www.docker.com/docker-toolbox)
- Get a Docker machine set up
  - `docker-machine create --driver virtualbox default`
  - `eval "$(docker-machine env default)"` - have to do in each terminal each time
  - `docker-machine ip default` - and record it
- Create a `Dockerfile`
- Create a `docker-compose.yml` file
- Update your Rails app DB config. Add `host: db` to `database.yml` dev and test, and remove username and password
- `docker-compose up`. then ctrl-c. this starts the DB. Watch the output to make sure there aren't errors.
- `docker-compose run web rake db:create db:migrate`
- `docker-compose up` again
- http://yourmachineip:3000

## Next Steps

To add other services, like a worker, Redis, or Mailcatcher, add new `docker-compose.yml` entries.