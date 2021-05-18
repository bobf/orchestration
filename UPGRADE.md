# Upgrade guide

## 0.5 to 0.6

### Delete/rename files

Delete all files from `orchestration/` directory except:

* `docker-compose.production.yml`
* `docker-compose.development.yml`
* `docker-compose.test.yml`
* `Dockerfile`
* `entrypoint.sh`

Rename:

```bash
orchestration/docker-compose.production.yml => orchestration/docker-compose.deployment.yml
```

Any environment-specific compose files (e.g. `staging`) should also be removed as the same compose file is now used for all deployment stages.

### Update Makefile

Remove the first line of the main `Makefile` (in root of project) and replace it with the new `include` declaration:

#### OLD

```make
include orchestration/Makefile
```

#### NEW

```make
include $(shell bundle exec ruby -e 'require "orchestration/make"')
```

#### Post-setup target

Add a new target anywhere in the `Makefile` called `post-setup`:

```make
.PHONY: post-setup
post-setup:
	echo 'doing post setup stuff'
```

Replace the body of this target with any commands that you want to take place once the initial setup (launching development/test containers, running migrations, etc.) is complete. For example, running migrations for a secondary database.

### Continuous Integration files

Update any continuous integration scripts (e.g. `Jenkinsfile`) to run the `setup` target before `test`, e.g.:

#### OLD

```Jenkinsfile
    stage('Test') {
      steps {
        sh 'make test sidecar=1'
      }
    }
```

#### NEW

```Jenkinsfile
    stage('Test') {
      steps {
        sh 'make setup test sidecar=1'
      }
    }
```

(`sidecar` may or may not be needed depending on your setup but, if it was there prior to upgrade, then it should remain after upgrade).

### General Usage

All _Orchestration_ commands behave exactly the same as before with the exception of the `test` target. Now, instead of running `make test` to launch all containers and then run tests, _Rubocop_, etc., you must run `make setup test`.

This will set up the test environment and then run tests. You may then run `make test` to just run tests without having to go through the full setup process again.

Similarly you can set up the development environment by just running `make setup`.

To set up the test environment and run tests as two separate steps (i.e. equivalent of using the shorthand `make setup test`) you can run:

```bash
make setup RAILS_ENV=test
make test
```
