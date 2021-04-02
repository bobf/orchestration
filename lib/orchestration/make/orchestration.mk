### Environment setup ###
SHELL:=/bin/bash
MAKE:=mkpath=${mkpath} make --no-print-directory

TERM ?= 'dumb'
pwd:=$(shell pwd)

orchestration_dir_name=orchestration
orchestration_dir=orchestration

ifdef env_file
  custom_env_file ?= 1
else
  custom_env_file ?= 0
endif

ifneq (,$(wildcard ${pwd}/config/database.yml))
  database_enabled = 1
else
  database_enabled = 0
endif

make=$(MAKE) $1
orchestration_config_filename:=.orchestration.yml
orchestration_config:=${pwd}/${orchestration_config_filename}
system_prefix=${reset}[${cyan}exec${reset}]
warn_prefix=${reset}[${yellow}warn${reset}]
echo_prefix=${reset}[${blue}info${reset}]
system=echo ${system_prefix} ${cyan}$1${reset}
warn=echo ${warn_prefix} ${reset}$1${reset}
echo=echo ${echo_prefix} ${reset}$1${reset}
print_error=printf '${red}\#${reset} '$1 | tee '${stderr}'
println_error=$(call print_error,$1'\n')
print=printf '${blue}\#${reset} '$1
println=$(call print,$1'\n')
printraw=printf $1
stdout=${pwd}/log/orchestration.stdout.log
stderr=${pwd}/log/orchestration.stderr.log
log_path_length=$(shell echo "${stdout}" | wc -c)
ifndef verbose
log_tee:= 2>&1 | tee -a ${stdout}
log:= >>${stdout} 2>>${stderr}
progress_point:=perl -e 'while( my $$line = <STDIN> ) { printf("."); select()->flush(); }'
log_progress:= > >(tee -ai ${stdout} >&1 | ${progress_point}) 2> >(tee -ai ${stderr} 2>&1 | ${progress_point})
endif
red:=$(shell tput setaf 1)
green:=$(shell tput setaf 2)
yellow:=$(shell tput setaf 3)
blue:=$(shell tput setaf 4)
magenta:=$(shell tput setaf 5)
cyan:=$(shell tput setaf 6)
gray:=$(shell tput setaf 7)
reset:=$(shell tput sgr0)
tick=[${green}✓${reset}]
cross=[${red}✘${reset}]
hr=$(call println,"$1$(shell head -c ${log_path_length} < /dev/zero | tr '\0' '=')${reset}")
managed_env_tag:=\# -|- ORCHESTRATION
standard_env_path:=${pwd}/.env
backup_env_path:=${pwd}/.env.orchestration.backup
is_managed_env:=$$(test -f '${standard_env_path}' && tail -n 1 '${standard_env_path}') == "${managed_env_tag}"*
token:=$(shell cat /dev/urandom | LC_CTYPE=C tr -dc 'a-z0-9' | fold -w8 | head -n1)
back_up_env:=( \
               [ ! -f '${standard_env_path}' ] \
             || \
               ( \
                 [ -f '${standard_env_path}' ] \
                 && cp '${standard_env_path}' '${backup_env_path}' \
               ) \
             )

key_chars:=[a-zA-Z0-9_]
censored:=**********
censor=s/\(^${key_chars}*$(1)${key_chars}*\)=\(.*\)$$/\1=${censored}/
censor_urls:=s|\([a-zA-Z0-9_+]\+://.*:\).*\(@.*\)$$|\1${censored}\2|
format_env:=sed '$(call censor,SECRET); \
                 $(call censor,TOKEN); \
                 $(call censor,PRIVATE); \
                 $(call censor,KEY); \
                 $(censor_urls); \
                 /^\s*$$/d; \
                 /^\s*\#/d; \
                 s/\(^[a-zA-Z0-9_]\+\)=/${blue}\1${reset}=/; \
                 s/^/  /; \
                 s/=\(.*\)$$/=${yellow}\1${reset}/' | \
            sort

fail=( \
       $(call printraw,' ${cross}') ; \
       $(call make,dump) ; \
       echo ; \
       $(call println,'Failed. ${cross}') ; \
       exit 1 \
    )

ifdef env_file
  -include ${env_file}
else
ifneq (${env},test)
ifeq (,$(findstring test,$(MAKECMDGOALS)))
  -include .env
endif
endif
endif

export

ifneq (,$(findstring test,$(MAKECMDGOALS)))
  env=test
endif

ifneq (,$(env))
  # `env` set by current shell.
else ifneq (,$(RAILS_ENV))
  env=$(RAILS_ENV)
else ifneq (,$(RACK_ENV))
  env=$(RACK_ENV)
else
  env=development
endif

printenv=${gray}${env}${reset}
DOCKER_TAG ?= latest

ifneq (,$(wildcard ./Gemfile))
  rake=DEVPACK_DISABLE=1 RACK_ENV=${env} RAILS_ENV=${env} bundle exec rake
else
  rake=RACK_ENV=${env} RAILS_ENV=${env} rake
endif

ifneq (,$(wildcard ${env_file}))
  rake_cmd:=${rake}
  rake=. ${env_file} && ${rake_cmd}
endif

ifeq (,$(findstring serve,$(MAKECMDGOALS)))
ifeq (,$(findstring console,$(MAKECMDGOALS)))
ifeq (,$(findstring test,$(MAKECMDGOALS)))
  docker_config:=$(shell DEVPACK_DISABLE=1 RAILS_ENV=development bundle exec rake orchestration:config)
  docker_organization=$(word 1,$(docker_config))
  docker_repository=$(word 2,$(docker_config))
endif
endif
endif

ifeq (,$(project_name))
  project_base = ${docker_repository}_${env}
else
  project_base := $(project_name)
endif

ifeq (,$(findstring deploy,$(MAKECMDGOALS)))
  sidecar_suffix := $(shell test -f ${orchestration_dir}/.sidecar && cat ${orchestration_dir}/.sidecar)
  ifneq (,${sidecar_suffix})
    sidecar := 1
  endif

  ifdef sidecar
    # Set the variable to an empty string so that "#{sidecar-1234}" will
    # evaluate to "1234" in port mappings.
    sidecar_compose = sidecar=''
    ifeq (,${sidecar_suffix})
      sidecar_suffix := $(call token)
      _ignore := $(shell echo ${sidecar_suffix} > ${orchestration_dir}/.sidecar)
    endif

    ifeq (,${sidecar_suffix})
      $(warning Unable to generate project suffix; project name collisions may occur.)
    endif
    compose_project_name = ${project_base}_${sidecar_suffix}
  else
    compose_project_name = ${project_base}
  endif
else
  compose_project_name = ${project_base}
endif

compose_base=env -i \
             PATH=$(PATH) \
             HOST_UID=$(shell id -u) \
             DOCKER_ORGANIZATION="${docker_organization}" \
             DOCKER_REPOSITORY="${docker_repository}" \
             COMPOSE_PROJECT_NAME="${compose_project_name}" \
	     ${sidecar_compose} \
             docker-compose \
             -f ${orchestration_dir}/docker-compose.${env}.yml

git_branch ?= $(if $(branch),$(branch),$(shell git rev-parse --abbrev-ref HEAD))
ifndef dev
  git_version ?= $(shell git rev-parse --short --verify ${git_branch})
else
  git_version = dev
endif

docker_image=${docker_organization}/${docker_repository}:${git_version}

compose=${compose_base}
printcompose=docker-compose -f ${orchestration_dir_name}/docker-compose.${env}.yml
random_str=cat /dev/urandom | LC_ALL=C tr -dc 'a-z' | head -c $1

ifneq (,$(wildcard ${orchestration_dir}/docker-compose.local.yml))
  compose:=${compose} -f ${orchestration_dir}/docker-compose.local.yml
endif

all: build

### Container management commands ###

.PHONY: start
ifndef network
start: network := ${compose_project_name}
endif
start: _create-log-directory _clean-logs
	@$(call system,${printcompose} up --detach)
ifeq (${env},$(filter ${env},test development))
	@${compose} up --detach --force-recreate --renew-anon-volumes --remove-orphans ${services} ${log} || ${fail}
	@[ -n '${sidecar}' ] && \
         ( \
           $(call echo,(joining dependency network ${cyan}${network}${reset}) ; \
           $(call system,docker network connect '${network}') ; \
           docker network connect '${network}' '$(shell hostname)' ${log} \
           || ( \
           $(call warn,Unable to join network: "${cyan}${network}${reset}". Container will not be able to connect to dependency services) ; \
           $(call info,Try deleting "${cyan}orchestration/.sidecar${reset}" if you do not want to use sidecar mode) ; \
           ) \
         ) \
         || ( [ -z '${sidecar}' ] || ${fail} )
else
	@${compose} up --detach --scale app=$${instances:-1} ${log} || ${fail}
endif
	@$(call echo,${printenv} containers started ${tick})
	@$(call echo,Waiting for services to become available)
	@$(call make,wait) 2>${stderr} || ${fail}

.PHONY: stop
stop: network := ${compose_project_name}
stop:
	@$(call echo,Stopping ${printenv} containers)
	@$(call system,${printcompose} down)
	@if docker ps --format "{{.ID}}" | grep -q $(shell hostname) ; \
          then \
            ( docker network disconnect ${network} $(shell hostname) ${log} || : ) \
            && \
            ( ${compose} down ${log} || ${fail} ) ; \
          else \
            ${compose} down ${log} || ${fail} ; \
          fi
	@$(call echo,${printenv} containers stopped ${tick})

.PHONY: logs
logs:
	@${compose} logs -f

.PHONY: config
config:
	@${compose} config

.PHONY: compose
compose:
	@echo ${compose}

### Development/Test Utility Commands

.PHONY: serve
serve: env_file ?= ./.env
serve: rails = RAILS_ENV='${env}' bundle exec rails server ${server}
serve:
	@if [ -f "${env_file}" ] ; \
         then ( \
                $(call echo,Environment${reset}: ${cyan}${env_file}${reset}) && \
                cat '${env_file}' | ${format_env} \
            ) ; \
        fi
	${rails}

.PHONY: console
console: env_file ?= ./.env
console: rails = RAILS_ENV='${env}' bundle exec rails
console:
	@if [ -f "${env_file}" ] ; \
         then ( \
                $(call echo,Environment${reset}: ${cyan}${env_file}${reset}') && \
                cat '${env_file}' | ${format_env} \
            ) ; \
        fi
	${rails} console

.PHONY: db-console
db-console:
	@${rake} orchestration:db:console RAILS_ENV=${env}

.PHONY: setup
setup: url = $(shell ${rake} orchestration:db:url RAILS_ENV=${env})
setup:
	@$(call echo,Setting up ${printenv} environment)
	@$(call make,start env=${env})
ifneq (,$(wildcard config/database.yml))
	@$(call echo,Preparing ${printenv} database)
	@$(call system,rake db:create DATABASE_URL='${url}')
	@${rake} db:create RAILS_ENV=${env} ${log} || : ${log}
  ifneq (,$(wildcard db/structure.sql))
	@$(call system,rake db:structure:load DATABASE_URL='${url}')
	@${rake} db:structure:load DATABASE_URL='${url}' ${log} || ${fail}
  else ifneq (,$(wildcard db/schema.rb))
	@$(call system,rake db:schema:load DATABASE_URL='${url}')
	@${rake} db:schema:load DATABASE_URL='${url}' ${log} || ${fail}
  endif
	@$(call system,rake db:migrate DATABASE_URL='${url}')
	@${rake} db:migrate RAILS_ENV=${env}
endif
	@$(MAKE) -n post-setup >/dev/null 2>&1 \
          && $(call system,make post-setup RAILS_ENV=${env}) \
          && $(MAKE) post-setup RAILS_ENV=${env}
	@$(call echo,${printenv} environment setup complete ${tick})

.PHONY: dump
dump:
ifndef verbose
	@$(call println)
	@$(call println,'${yellow}Captured${reset} ${green}stdout${reset} ${yellow}and${reset} ${red}stderr${reset} ${yellow}log data [${cyan}${env}${yellow}]${reset}:')
	@$(call println)
	@echo
	@test -f '${stdout}' && ( \
          $(call hr,${green}) ; \
          $(call println,'${gray}${stdout}${reset}') ; \
          $(call hr,${green}) ; \
          echo ; cat '${stdout}' ; echo ; \
          $(call hr,${green}) ; \
        )

	@test -f '${stdout}' && ( \
          echo ; \
          $(call hr,${red}) ; \
          $(call println,'${gray}${stderr}${reset}') ; \
          $(call hr,${red}) ; \
          echo ; cat '${stderr}' ; echo ; \
          $(call hr,${red}) ; \
        )
endif
	@echo ; \
        $(call hr,${yellow}) ; \
        $(call println,'${gray}docker-compose logs${reset}') ; \
        $(call hr,${yellow}) ; \
        echo
	@${compose} logs
	@echo ; \
        $(call hr,${yellow})
	@$(NOOP)

.PHONY: image
image:
	@echo ${docker_image}

### Deployment utility commands ###

.PHONY: deploy
ifdef env_file
deploy: env_file_option = --env-file ${env_file}
endif
deploy: RAILS_ENV := ${env}
deploy: RACK_ENV := ${env}
deploy: DOCKER_TAG = ${git_version}
deploy: base_vars = DOCKER_ORGANIZATION=${docker_organization} DOCKER_REPOSITORY=${docker_repository} DOCKER_TAG=${git_version}
deploy: compose_deploy := ${base_vars} COMPOSE_PROJECT_NAME=${project_base} HOST_UID=$(shell id -u) docker-compose ${env_file_option} --project-name ${project_base} -f orchestration/docker-compose.production.yml
deploy: deploy_cmd := ${compose_deploy} config | ssh "${manager}" "/bin/bash -lc 'cat | docker stack deploy --prune --with-registry-auth -c - ${project_base}'"
deploy:
ifndef manager
	@$(call fail,Missing `manager` parameter: `make deploy manager=swarm-manager.example.com`) ; exit 1
endif
	@$(call echo,Deploying ${printenv} stack via ${cyan}${manager}${reset} as ${cyan}${project_base}${reset}) && \
          ( \
             $(call echo,Deployment environment:) && \
             ( test -f '${env_file}' && cat '${env_file}' | ${format_env} || : ) && \
             $(call echo,Application image: ${cyan}${docker_image}${reset}) ; \
	     $(call system,${deploy_cmd}) ; \
	     ${deploy_cmd} ; \
             if [[ "$${deploy_exit_code}" == 0 ]] ; then exit 0 ; fi ; \
          ) \
          || ${fail}

	@$(call echo,Deployment ${green}complete${reset} ${tick})

.PHONY: rollback
ifndef service
rollback: service = app
endif
rollback:
ifndef manager
	@$(call fail,Missing `manager` parameter: `make deploy manager=swarm-manager.example.com`)
	@exit 1
endif
	@$(call echo,Rolling back ${cyan}${compose_project_name}_${service}${reset} via ${cyan}${manager}${reset} ...)
	@$(call system,docker service rollback --detach "${compose_project_name}_${service}")
	@ssh "${manager}" 'docker service rollback --detach "${compose_project_name}_${service}"' ${log} || ${fail}
	@$(call echo,Rollback request ${green}complete${reset} ${tick})

### Service healthcheck commands ###

.PHONY: wait
wait:
	@${rake} orchestration:wait
	@$(call echo,${printenv} services ${green}ready${reset} ${tick})

## Generic Listener healthcheck for TCP services ##

wait-listener:
	@${rake} orchestration:listener:wait service=${service} sidecar=${sidecar}

### Docker build commands ###

.PHONY: build
build: build_dir = ${orchestration_dir}/.build
build: context = ${build_dir}/context.tar
build: build_args := --build-arg GIT_COMMIT='${git_version}'
ifdef BUNDLE_GITHUB__COM
build: build_args := ${build_args} --build-arg BUNDLE_GITHUB__COM
endif
ifdef BUNDLE_BITBUCKET__ORG
build: build_args := ${build_args} --build-arg BUNDLE_BITBUCKET__ORG
endif
build: _create-log-directory check-local-changes
	@$(call echo,Preparing build context from ${cyan}${git_branch}:${git_version}${reset})
	@$(call system,git archive --format 'tar' -o '${context}' '${git_branch}')
	@mkdir -p ${orchestration_dir}/.build ${log} || ${fail}
ifndef dev
	@git show ${git_branch}:./Gemfile > ${orchestration_dir}/.build/Gemfile 2>${stderr} || ${fail}
	@git show ${git_branch}:./Gemfile.lock > ${orchestration_dir}/.build/Gemfile.lock 2>${stderr} || ${fail}
	@git archive --format 'tar' -o '${context}' '${git_branch}' ${log} || ${fail}
else
	@tar -cvf '${context}' . ${log} || ${fail}
endif
ifdef include
	@$(call echo,Including files from: ${cyan}${include}${reset})
	@(while read line; do \
	    _system () { ${system_prefix} $$1 }
            export line; \
            include_dir="${build_dir}/$$(dirname "$${line}")/" && \
            mkdir -p "$${include_dir}" && cp "$${line}" "$${include_dir}" \
            && (cd '${orchestration_dir}/.build/' && tar rf 'context.tar' "$${line}"); \
	    _system "tar rf 'context.tar' '$${line}'")
          done < '${include}') ${log} || ${fail}
	@$(call echo,Build context ${green}ready${reset} ${tick})
endif
	@$(call echo,Building image)
	@$(call system,docker build ${build_args} -t ${docker_organization}/${docker_repository}:${git_version} ${orchestration_dir}/) \
	@docker build ${build_args}
                        -t ${docker_organization}/${docker_repository} \
                        -t ${docker_organization}/${docker_repository}:${git_version} \
                        ${orchestration_dir}/ ${log_progress} || ${fail}
	@$(call echo,Docker image build ${green}complete${reset} ${tick})
	@$(call echo,[${green}tag${reset}] ${cyan}${docker_organization}/${docker_repository}${reset})
	@$(call echo,[${green}tag${reset}] ${cyan}${docker_organization}/${docker_repository}:${git_version}${reset})

.PHONY: push
push: _create-log-directory
	@$(call echo,Pushing ${cyan}${docker_image}${reset} to Docker Hub)
	@$(call system,docker push ${docker_image})
	@docker push ${docker_image} ${log_progress} || ${fail}
	@$(call echo,Push ${green}complete${reset} ${tick})

.PHONY: check-local-changes
check-local-changes:
ifndef dev
	@changes="$$(git status --porcelain)"; if [[ "${changes}" ! -z ]] && [[ "${changes}" != "?? orchestration/.sidecar" ]]; \
         then \
           $(call warn,You have uncommitted changes which will not be included in your build:) ; \
           git status --porcelain ; \
           $(call echo,Commit these changes to Git or, alternatively, build in development mode to test your changes before committing: ${cyan}make build dev=1${reset}) ; \
         fi
endif

### Internal Commands ###
#
.PHONY: _clean-logs
_clean-logs:
	@rm -f '${stdout}' '${stderr}'
	@touch '${stdout}' '${stderr}'

.PHONY: _create-log-directory
_create-log-directory:
	@mkdir -p log

# Used by Orchestration test suite to verify Makefile syntax
.PHONY: _test
_test:
	@echo 'test command'
