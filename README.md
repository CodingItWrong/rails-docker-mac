# How to Even Run Rails on Docker on Mac

This README is a tutorial for how to get a Rails app running inside Docker on a Mac for local development. You can also clone this repo to get a Rails app pre-configured to run in Docker--the instructions below will tell you which steps you can skip, but you still need to run the rest.

As a caveat, I have only very limitrd experience with Docker. There may be much better ways to do these things. Please send a pull request with any corrections or improvements!

## Sources

This tutorial was made with information from the following sources:

- [Docker for Mac - Getting Started](https://docs.docker.com/docker-for-mac/)
- [Docker Compose - Rails Quickstart Guide](https://docs.docker.com/compose/rails/)
- [RailsConf 2015 - DevOps for The Lazy](https://www.youtube.com/watch?v=CVO_imNSw2o) (video)

This assumes you already have a working Rails application that's `bundle install`ed and is configured for a Postgres database. (You can create a Rails app from within Docker, too, but it's more complex than I wanted to make this tutorial. [Instructions here.](https://docs.docker.com/compose/rails/))

## The Steps

### Install Docker

First, you need to install [Docker for Mac](https://docs.docker.com/docker-for-mac/). The installation is just a one-time thing, of course: once you've done this, you don't need to do it again, at least until Jony Ive releases a new thinner MacBook Pro.

### Configure Docker and Docker Compose

First you need to set up the Docker containers that your application needs. Note that I said *containers*, plural: your Rails application and your Postgres database will be in two separate containers. This is one of the main advantages of a container-based infrastructure like Docker: instead of having to install multiple software packages like Rails and Postgres on one machine, you just download a container for each component you need.

**Note:** if you're running this repo's Rails app, these steps have already been done, so you don't need to do them. But you can take a look at the files it references to learn what's involved.

1. **Create a `Dockerfile` at your project's root with a single line:** `FROM rails:onbuild`. This specifies that the container that runs your web application should use the `rails:onbuild` image. It's an image that's preconfigured to run Rails. You can learn more about it at [its Docker Hub page](https://hub.docker.com/_/rails/).
2. **Create a `docker-compose.yml` file at your project's root with the contents below.** By default, Docker is run with command-line commands. But running multiple containers requires multiple commands, and this can get a bit tedious. Docker Compose allows you to write a single config file that specifies what containers you need, making running them a lot simpler. Your `docker-compose.yml` file should contain the following:

    ```yml
    db:
      image: postgres
    web:
      build: .
      volumes:
        - .:/usr/src/app
      ports:
        - "3000:3000"
      links:
        - db
    ```

  Here's what each entry means:

  - `db` and `web` are two different containers: one for running your database and another for your webapp.
  - `db` just has a single entry, `image`. This says to use a pre-built Docker image; in this case, `postgres`. As you can guess, this is a Docker image that runs the Postgres database server. [Details here.](https://hub.docker.com/_/postgres/)
  - Under `web`, `build` specifies that Docker should build a new image from the current directory. It uses the `Dockerfile` you set up in that directory.
  - `volumes` mounts your project folder inside the container, so changes you make to the code show up immediately.
  - `ports` exposes ports to your host machine. In this case, we need to get access to port 3000 because that's where Rails will run, and we want to expose it as port 3000 on the host. (Because we're using Docker Machine, the "host" is the Docker virtual machine, so we'll access it at the IP address we wrote down above.)
  - `links` specifies other containers that this container should have access to. In this case, we want `web` to have access to `db` so it can use the database. It will be made available from the `web` container under the hostname `db`.

3. **Update your Rails `database.yml` config file to point to the Postgres container.** Your database will no longer effectively be running on localhost; the separate Docker containers act like separate servers on a private network. In `database.yml`, your `development` database should have the following entries (note that the password is blank):

    ```yml
    development:
      ...
      host: db
      username: postgres
      password:
    ```

### Start Up Docker

Now that you have a running Docker virtual machine and a Docker Compose setup for your app, it's time to actually run your app. You use Docker Compose to run the individual Docker commands to set up the containers the way you scripted them.

4. **Run `docker-compose up`, then, when it's finished, press ctrl-C.** This starts up the containers, but we don't actually want to run the app yet. We want to migrate the database first. (There is probably a better way to do this than having to ctrl-C out, but I haven't found it yet.)
5. **Run `docker-compose run web rake db:create db:migrate` to set up your database.** If you do this before running `docker-compose up`, you may run into errors.
6. **Run `docker-compose up` again to start your app.**
7. **View your app by going to <http://localhost:3000>**

## Next Steps

To add other services, like a worker, Redis, or Mailcatcher, add new `docker-compose.yml` entries. If it's a common technology, you can usually find an image for it on [Docker Hub](https://hub.docker.com/). Its entry in your `docker-compose.yml` will look a lot like the `db` one: just pointing to an image.

## License

MIT. See LICENSE for more details.
