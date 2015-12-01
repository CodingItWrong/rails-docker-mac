# How to Even Run Rails on Docker on Mac

This README is a tutorial for how to get a Rails app running inside Docker on a Mac for local development. You can also clone this repo to get a Rails app pre-configured to run in Docker--the instructions below will tell you which steps you can skip, and you still need to run the rest.

As a caveat, I have only enough experience with Docker to have gotten a Rails app running in it. I'm sure there are much better ways to do many of these things. Please send a pull request with any corrections or improvements!

## Sources

This tutorial was made with information from the following sources:

- [Docker Machine - Getting Started](https://docs.docker.com/machine/get-started/)
- [Docker Compose - Rails Quickstart Guide](https://docs.docker.com/compose/rails/)
- [RailsConf 2015 - DevOps for The Lazy](https://www.youtube.com/watch?v=CVO_imNSw2o) (video)

This assumes you already have a working Rails application that's `bundle installed` and is configured for a Postgres database. (You can create a Rails app from within Docker, too, but it's more complex than I wanted to make this tutorial. [Instructions here.](https://docs.docker.com/compose/rails/))

## The Steps

### Install Docker

First, you need to install Docker on your Mac. Specifically, you need to install the [Docker Toolbox](https://www.docker.com/docker-toolbox). This includes several command-line tools you'll need:

- **Docker Machine**: to set up a virtual machine so you can run Docker on a Mac.
- **Docker Compose**: to script out setting up multiple Docker containers your app will need.
- **Vagrant and VirtualBox**: You'll need both of these as well. Docker Toolbox says it installs VirtualBox; it doesn't say whether it installs Vagrant. I already had both of those installed on my Mac so I can't say for sure. If you try this tutorial and run into an issue where you had to manually install one or both, [let me know](https://twitter.com/CodingItWrong)!

The above installation is just a one-time thing, of course: once you've done this, you don't need to do it again, at least until Jony Ive releases a new thinner MacBook Pro.

### Set Up a Docker Machine

Docker only runs natively on Linux, because of the way containers work. To run it on a Mac, you actually need to run it inside a Linux virtual machine. Thankfully, Docker Machine makes this trivial, so you almost don't need to think about it.

1. **From the command line, run `docker-machine create --driver virtualbox default`.** This creates a Docker Machine named "default".
2. **Run `eval "$(docker-machine env default)"`.** This sets some environment variables in your current terminal that allow Docker Compose to connect to it. Running the command in an `eval` actually sets those environment variables in your terminal. If you want to send Docker Machine or Docker Compose commands from multiple terminals, you'll need to run `eval "$(docker-machine env default)"` in each terminal.
3. **Run `docker-machine ip default` and record the IP address it gives you.** That's the IP address your Docker Machine is running on. That's what you'll use to access the web application later.

### Configure Docker and Docker Compose

Next you need to set up the Docker containers that your application needs. Note that I said *containers*, plural: your Rails application and your Postgres database will be in two separate containers. This is one of the main advantages of a container-based infrastructure like Docker: instead of having to install multiple software packages like Rails and Postgres on one machine, you just download separate containers for each separate component you need.

**Note:** if you're running this repo's Rails app, these steps have already been done, so you don't need to do them. But you can take a look at the files it references to learn what's involved.

4. **Create a `Dockerfile` at your project's root with a single line:** `FROM rails:onbuild`. This specifies that the container that runs your web application should use the `rails:onbuild` image. It's an image that's preconfigured to run Rails. You can learn more about it at [its Docker Hub page](https://hub.docker.com/_/rails/).
5. **Create a `docker-compose.yml` file at your project's root with the contents below.** By default, Docker is run with multiple command-line commands. Docker Compose allows you to write a single config file that specifies what containers you need, making running them a lot simpler. Your `docker-compose.yml` file should contain the following:

    ```yml
    db:
      image: postgres
    web:
      build: .
      ports:
        - "3000:3000"
      links:
        - db
    ```

  Here's what each entry means:

  - `db` and `web` are two different containers: one for running your database and another for your webapp.
  - `db` just has a single entry, `image`. This says to use a pre-built Docker image; in this case, `postgres`. As you can guess, this is a Docker image that runs the Postgres database server. [Details here.](https://hub.docker.com/_/postgres/)
  - Under `web`, `build` specifies that Docker should build a new image from the current directory. It uses the `Dockerfile` you set up in that directory.
  - `ports` exposes ports to your host machine. In this case, we need to get access to port 3000 because that's where Rails will run.
  - `links` specifies other containers that this container should have access to. In this case, we want `web` to have access to `db` so it can use the database. It will be made available from the `web` container simply as the hostname `db`.

6. **Update your Rails `database.yml` config file to point to the Postgres container.** Your database will no longer effectively be running on localhost; the separate Docker containers act like separate servers on a private network. In `database.yml`, your `development` database should have the following entries (note that the password is blank):

    ```yml
    development:
      ...
      host: db
      username: postgres
      password:
    ```

### Start Up Docker

Now that you have a running Docker Machine and a Docker Compose setup for your app, it's time to actually run your app. You use Docker Compose to run the individual Docker commands to set up the containers the way you scripted them. Docker Machine is the virtual machine they'll run inside.

7. **Run `docker-compose up`, then, when it's finished, press ctrl-C.** This starts up the containers, but we don't actually want to run the app yet. We want to migrate the database first. (There is probably a better way to do this than having to ctrl-C out, but I haven't found it yet.)
8. **Run `docker-compose run web rake db:create db:migrate` to set up your database.** If you do this before running `docker-compose up`, you may run into errors.
9. **Run `docker-compose up` again to start your app.**
10. **View your app by going to http://yourmachineip:3000**, where "yourmachineip" is the IP address you wrote down in step 3: usually a 192.168 address.

## Next Steps

To add other services, like a worker, Redis, or Mailcatcher, add new `docker-compose.yml` entries.

## License

MIT. See LICENSE for more details.