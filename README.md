# Orchestration

## Overview

_Orchestration_ provides a toolkit for building and launching _Rails_ applications and dependencies in _Docker_.

A suite of tools is provided to assist in creating configuration files, launching service dependencies, verifying that dependencies have launched successfully (e.g. for running tests in contiuous integration tools), and building, tagging, and pushing _Docker_ images.

Containers are automatically created for the following dependencies:

* MySQL
* MongoDB
* PostgreSQL
* RabbitMQ

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'orchestration', '~> 0.3.1'
```

And then build your bundle:
``` bash
$ bundle install
```

## Usage

### Generating configuration files

A _Rake_ task is provided to generate the following files:

* `.gitignore` - ensures any unwanted files created by _Orchestration_ do not clutter your project's version control system.
* `.orchestration.yml` - _Orchestration_ internal configuration, e.g. _Docker_ username.
* `Makefile` - Adds `orchestration/Makefile` as an `include` to avoid clobbering any existing _make_ commands.
* `orchestration/docker-compose.yml` - a custom-made set of services to allow you to run your application's dependencies locally.
* `orchestration/Dockerfile` - a ready-to-use _Docker_ build script which should need minimal (if any) modification to build your _Rails_ project.
* `orchestration/entrypoint.sh` - Container setup for your Docker application.
* `orchestration/Makefile` - provides easy access to all _Orchestration_ utilities.
* `orchestration/yaml.bash` - A _bash_ _YAML_ parser (used by _make_ utilities).

### Building and pushing your project as a _Docker_ image

#### Private Git repository authentication

If your project has any dependencies on private  _Git_ repositories then you will need to create an authentication token. See the relevant documentation for your _Git_ host:

* [GitHub](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/)
* [Bitbucket](https://confluence.atlassian.com/bitbucket/app-passwords-828781300.html)

Create a file named `.env` in your project's root directory and add one or both of the following (note that _Bitbucket_ and _GitHub_ use a different format):

```bash
BUNDLE_BITBUCKET__ORG=<bitbucket-username>:<app-password>
BUNDLE_GITHUB__COM=x-oauth-basic:<auth-token>
```

#### Docker installation
_Docker_ must be installed on your system. See the [_Docker_ getting started guide](https://www.docker.com/get-started) for instructions.

#### DockerHub account

You will need an account with _Docker Hub_ (or your preferred _Docker_ image host) to push your images. Visit the [_Docker Hub_ webpage](https://hub.docker.com/) to sign up, then run the following command and enter your credentials when prompted to log in to your new account:
```bash
$ docker login
```

#### Using provided `Makefile`

To build and push your image run:
```bash
$ make docker
```

Or run the two steps separately:
```bash
$ make docker-build
$ make docker-push
```

### Starting and waiting for services when running your tests

To start services:

```bash
$ make start
```

It is recommended that you create a `test` command in your `Makefile` which will launch all dependencies and wait for them to be ready before running all tests. For example:

```Makefile
test: start wait
	bundle exec rspec
	yarn test app/javascript
	bundle exec rubocop
	yarn run eslint app/javascript
```

This is especially useful for continuous integration as it provides a uniform command (`make test`) that can be run by your CI tool without any extra setup.
