# Orchestration

_Orchestration_ is a toolkit for testing, building, and deploying _Ruby_ (including _Rails_) applications in _Docker_.

## Getting Started

[_Docker_](https://www.docker.com/get-started) and [_Docker Compose_](https://docs.docker.com/compose/install/) must be installed on your system.

### Install

Add _Orchestration_ to your Gemfile:

```ruby
gem 'orchestration', '~> 0.3.12'
```

Install:

```bash
bundle install
```

### Setup

Generate configuration files:

```bash
bin/rake orchestration:install
```

Commit changes:

```bash
git add .
git commit -m "Add Orchestration gem"
```

## Usage

Start your dependencies:

```bash
make start
```

Log in to your _Docker_ registry, then build and push your image:
```bash
docker login
make build push
```

Make a compact, portable, production-ready tarball:
```
make bundle
```

Copy tarball to your server and unpack:
```bash
tar xf deploy.tar
cd <your-app-name>/
```

Add required config to `.env` file:
```
# .env
SECRET_KEY_BASE=<your-secure-token>
LISTEN_PORT=8080
VIRTUAL_HOST=yourdomain.com
```

Load three instances of your container, load-balanced by _Nginx_, with dependecies:
```
make start instances=3
```

Or deploy to _Docker Swarm_:
```
make deploy
```

## Table of Contents

<!-- toc -->

- [Configuration Files](#configuration-files)
  * [Makefile](#makefile)
  * [.orchestration.yml](#orchestrationyml)
  * [.env](#env)
  * [orchestration/Dockerfile](#orchestrationdockerfile)
  * [orchestration/entrypoint.sh](#orchestrationentrypointsh)
  * [orchestration/docker-compose.yml](#orchestrationdocker-composeyml)
  * [config/unicorn.rb](#configunicornrb)
- [Building](#building)
- [Build Environment](#build-environment)
- [Commands](#commands)
- [Dependencies](#dependencies)

<!-- tocstop -->

## Configuration Files

_Orchestration_ autogenerates boilerplate configuration based on your application's requirements and configuration.

When supported dependencies are detected they will be created as services in your _Docker Compose_ configurations ready for use in testing, development, and production.

The following files are created on setup:

### Makefile

Contains an `include` for the main _Orchestration_ `Makefile`. If this file already exists then the `include` will be added to the top of the file.

### .orchestration.yml

_Orchestration_-specific configuration such as your _Docker_ registry and username.

### .env

Specify any environment variables (e.g. `SECRET_KEY_BASE`) your application will need to run in production mode.

The following two variables _must_ be defined:

```bash
VIRTUAL_HOST=localhost
LISTEN_PORT=3000
```

When running in production mode your application will be load-balanced by _Nginx_ proxy and available at http://localhost:3000/

Take a look at `orchestration/docker-compose.production.yml` to see what variables will be exposed to various containers.

### orchestration/Dockerfile

The basic requirements of a typical _Rails_ application. It is optimised for build speed and will automatically build assets (with our without `Webpacker`).

### orchestration/entrypoint.sh

Entrypoint script to handle user switching, permissions, stale pidfiles, etc.

### orchestration/docker-compose.yml

Along with the base `docker-compose.yml` a separate configuration is created for each environment. An override file is also generated.

See related documentation:

https://docs.docker.com/compose/extends/

* `orchestration/docker-compose.yml`
* `orchestration/docker-compose.test.yml`
* `orchestration/docker-compose.development.yml`
* `orchestration/docker-compose.production.yml`
* `orchestration/docker-compose.override.yml`

You can modify these files to suit your requirements.

The famous [`jwilder/nginx-proxy`](https://github.com/jwilder/nginx-proxy) is used to load-balance replicas of your application when running in production.

### config/unicorn.rb

If not already present, a [Unicorn](https://bogomips.org/unicorn/) configuration will be created. This is the default server when running in production.

## Building

_Orchestration_ provides tools for building your application as a _Docker_ image.

```bash
make build
```

Running `make build` does the following:

* Takes a snapshot of your application from current _Git_ `HEAD`. Only committed files are included.
* Copies your `Gemfile` and installs your bundle (optimised for _Docker_ image caching).
* Tags your image with your configured username/organisation, repository, and the current commit hash (abbreviated) of `HEAD`, e.g. `myorg/myapp:abc123`

Your image can then be pushed to your configured registry (use `docker login` before running):

```
make push
```

## Build Environment

The following environment variables will be passed as `ARG` variables when building your image:

```
BUNDLE_BITBUCKET__ORG
BUNDLE_GITHUB__COM
```

See related documentation:

* https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/
* https://confluence.atlassian.com/bitbucket/app-passwords-828781300.html

## Commands

_Orchestration_ provides a number of `make` commands to help you work with your application in _Docker_.

All commands respect `RAILS_ENV` or `RACK_ENV`. Alternatively you can pass `env` to any command:
```bash
make config env=production
```

The following commands are implemented:

| Command | Description |
|---|---|
| `start` | Start all containers and wait for their services to become available. In production mode, pass `instances=N` to start `N` replicas of your app. |
| `stop` | Stop all containers. |
| `logs` | Tail logs for all containers. |
| `config` | Output the full configuration for the current environment with all variables substituted. |
| `compose` | Output full `docker-compose` command. Run arbitrary commands for your environment, e.g. `$(make compose env=test) ps --services` |
| `test-setup` | Launch test dependency containers, wait for them to become ready, run database migrations. Call before running tests in a CI environment. |
| `wait` | Wait for all dependencies to be ready (i.e. verify that database is up and accepting connections, etc.). |
| `wait-database` | Wait for database container (supported: _PostgreSQL_ and _MySQL_) to become available. |
| `wait-mongo` | Wait for _Mongo_ container to become available.
| `wait-rabbitmq` | Wait for _RabbitMQ_ container to become available. |
| `wait-nginx_proxy` | Wait for _Nginx_ container to become available (`production` only). |
| `wait-app` | Wait for main application container to become available (`production` only). |
| `build` | Build your application as a _Docker_ image. |
| `push` | Push the current version of your application image to a _Docker_ registry. |
| `bundle` | Create `deploy.tar` which contains pre-cooked production configurations and `Makefile` ready to deploy your application on any machine with _Docker_ and _Docker Compose_ installed.

## Dependencies

Dependencies are automatically detected. The following services are currently supported:

| Service | Configuration File |
|---|---|
| _PostrgeSQL_ | `config/database.yml` |
| _MySQL_ | `config/database.yml` |
| _RabbitMQ_ | `config/rabbitmq.yml` |
| _Mongo_ | `config/mongoid.yml` |

Running `bin/rake orchestration:install` will automatically add services to your _Compose_ configurations that reflect your configuration files.

For _RabbitMQ_, `config/rabbitmq.yml` should contain `host` and `port` fields for each environment.
