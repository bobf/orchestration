# Orchestration

## Overview

_Orchestration_ provides a toolkit for building and launching _Rails_ applications and dependencies in _Docker_.

A suite of tools is provided to assist in creating configuration files, launching service dependencies, verifying that dependencies have launched successfully (e.g. for running tests in contiuous integration tools), and building, tagging, and pushing _Docker_ images.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'orchestration_orchestration', git: 'https://bitbucket.org/orchestration_developers/orchestration_orchestration'
```

And then build your bundle:
``` bash
$ bundle install
```

## Usage

### Generating configuration files

A _Rake_ task is provided to generate the following files:

* `Makefile` - provides easy access to all _Orchestration_ utilities.
* `.gitignore` - ensures any unwanted files created by _Orchestration_ do not clutter your project's version control system.
* `docker/Dockerfile` - a ready-to-use _Docker_ build script which should need minimal (if any) modification to build your _Rails_ project.
* `docker-compose.yml` - a custom-made set of services to allow you to run your application's dependencies locally.

### Building and pushing your project as a _Docker_ image

#### Prerequisites

If your project has any dependencies on private _Git_ repositories then you will need to create a _Bitbucket_ app password.

See the [Atlassian documentation on app passwords](https://confluence.atlassian.com/bitbucket/app-passwords-828781300.html) and follow the instructions.

Copy your app password and make it available in your shell by adding the following (replacing the substitute values) to your `~/.bash_profile`:

```bash
export BUNDLE_BITBUCKET__ORG=<bitbucket-username>:<app-password>
```

_Docker_ must be installed on your system. See the [_Docker_ getting started guide](https://www.docker.com/get-started) for instructions.

You will also need a _Docker Hub_ account. Visit the [_Docker Hub_ webpage](https://hub.docker.com/) to sign up. Then run the following command and enter your credentials when prompted to log in to your new account:
```bash
$ docker login
```

Finally, you will need to have your _Docker Hub_ account added to the `orchestrationdev` organisation - speak to your team leader for further information.

#### Using provided `Makefile`

To build your project as a _Docker_ image run the following command:
```bash
$ make docker-build
```

This will create a new image tagged as `orchestrationdev/<your-project-name>` versioned using the current short version of the latest _Git_ commit hash on master, e.g. `a1d5d6b`.

You can then push your image to _Docker Hub_:
```bash
$ make docker-push
```

Or run both commands in sequence:
```
$ make docker
```

### Starting and waiting for services when running your tests

To start services:

```bash
$ make start
```

This will launch any dependencies your project needs (e.g. SQL _MySQL_, _MongoDB_, etc.).

To wait for all services to be ready:
```bash
$ make wait
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
