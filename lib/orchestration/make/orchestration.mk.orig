
### Environment setup ###
SHELL:=/bin/bash
MAKE:=mkpath=${mkpath} make --no-print-directory
ORCHESTRATION_DISABLE_ENV=1
export
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

make=$(MAKE) $1
orchestration_config_filename:=.orchestration.yml
orchestration_config:=${pwd}/${orchestration_config_filename}
system_prefix=${reset}[${cyan}exec${reset}]
warn_prefix=${reset}[${yellow}warn${reset}]
echo_prefix=${reset}[${blue}info${reset}]
fail_prefix=${reset}[${red}fail${reset}]
logs_prefix=${reset}[${green}logs${reset}]
system=echo '${system_prefix} ${cyan}$1${reset}'
warn=echo '${warn_prefix} ${reset}$1${reset}'
echo=echo '${echo_prefix} ${reset}$1${reset}'
fail=echo '${fail_prefix} ${reset}$1${reset}'
logs=echo '${logs_prefix} ${reset}$1${reset}'
print_error=printf '${red}\#${reset} '$1 | tee '${stderr}'
println_error=$(call print_error,$1'\n')
print=printf '${blue}\#${reset} '$1
println=$(call print,$1'\n')
printraw=printf $1
stdout=${pwd}/log/orchestration.stdout.log
stderr=${pwd}/log/orchestration.stderr.log
log_path_length:=$(shell echo "${stdout}" | wc -c)
ifndef verbose
log_tee:= 2>&1 | tee -a ${stdout}
log:= >>${stdout} 2>>${stderr}
progress_point:=perl -e 'printf("[${magenta}busy${reset}] "); while( my $$line = <STDIN> ) { printf("."); select()->flush(); }'
log_progress:= > >(tee -ai ${stdout} >&1 | ${progress_point}) 2> >(tee -ai ${stderr} 2>&1 | ${progress_point})
endif
hr:=$(call println,"$1$(shell head -c ${log_path_length} < /dev/zero | tr '\0' '=')${reset}")
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

exit_fail=( \
           $(call printraw,' ${cross}') ; \
           $(call make,dump src_cmd=$(MAKECMDGOALS)) ; \
           echo ; \
           $(call println,'Failed. ${cross}') ; \
           exit 1 \
        )

ifdef env_file
  env_path=${env_file}
else
  env_path=.env
endif

ifneq (${env},test)
  ifeq (,$(findstring test,$(MAKECMDGOALS)))
    ifeq (,$(findstring deploy,$(MAKECMDGOALS)))
      ifeq (,$(findstring setup,$(MAKECMDGOALS)))
        -include ${env_path}
      endif
    endif
  endif
endif

ifneq (,$(findstring deploy,$(MAKECMDGOALS)))
  RAILS_ENV=$(shell grep '^RAILS_ENV=' '${env_path}' | tail -n1 | sed 's/^RAILS_ENV=//')
endif

export

ifneq (,$(findstring test,$(MAKECMDGOALS)))
  env=test
endif

ifneq (,$(RAILS_ENV))
  env=$(RAILS_ENV)
else ifneq (,$(env))
  # `env` set by current shell.
else ifneq (,$(RAILS_ENV))
  env=$(RAILS_ENV)
else ifneq (,$(RACK_ENV))
  env=$(RACK_ENV)
else
  env=development
endif

env_human=${gray}${env}${reset}
DOCKER_TAG ?= latest

ifneq (,$(wildcard ./Gemfile))
  bundle_cmd = bundle exec
endif
rake=ORCHESTRATION_DISABLE_ENV=1 DEVPACK_DISABLE=1 RACK_ENV=${env} SECRET_KEY_BASE='placeholder-secret' RAILS_ENV=${env} ${bundle_cmd} rake

ifneq (,$(wildcard ${env_file}))
  ifeq (,$(findstring deploy,$(MAKECMDGOALS)))
    rake_cmd:=${rake}
    rake=. ${env_file} && ${rake_cmd}
  endif
endif

docker_config:=$(shell DEVPACK_DISABLE=1 RAILS_ENV=development ${bundle_cmd} rake orchestration:config 2>/dev/null || echo no-org no-repo)
docker_organization=$(word 1,$(docker_config))
docker_repository=$(word 2,$(docker_config))

compose_services:=$(shell ${rake} orchestration:compose_services RAILS_ENV=${env})

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
    compose_project_name_base = ${project_base}_${sidecar_suffix}
  else
    compose_project_name_base = ${project_base}
  endif
else
  compose_project_name_base = ${project_base}
endif

ifdef COMPOSE_PROJECT_NAME_SUFFIX
  compose_project_name = ${compose_project_name_base}_${COMPOSE_PROJECT_NAME_SUFFIX}
else
  compose_project_name = ${compose_project_name_base}
endif

compose_base:=env -i \
             PATH=$(PATH) \
             HOST_UID=$(shell id -u) \
             DOCKER_ORGANIZATION="${docker_organization}" \
             DOCKER_REPOSITORY="${docker_repository}" \
             COMPOSE_PROJECT_NAME="${compose_project_name}" \
             COMPOSE_PROJECT_NAME_SUFFIX="${COMPOSE_PROJECT_NAME_SUFFIX}" \
	     ${sidecar_compose} \
             docker-compose \
             -f ${orchestration_dir}/docker-compose.${env}.yml

git_branch := $(if $(branch),$(branch),$(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo no-branch))
ifndef dev
  git_version := $(shell git rev-parse --short --verify ${git_branch} 2>/dev/null || echo no-version)
else
  git_version := dev
endif

docker_image:=${docker_organization}/${docker_repository}:${git_version}

compose=${compose_base}
compose_human=docker-compose -f ${orchestration_dir_name}/docker-compose.${env}.yml
random_str=cat /dev/urandom | LC_ALL=C tr -dc 'a-z' | head -c $1

ifneq (,$(wildcard ${orchestration_dir}/docker-compose.local.yml))
  compose:=${compose} -f ${orchestration_dir}/docker-compose.local.yml
endif

all: build

### Container management commands ###

.PHONY: pull
pull:
	@$(call system,${compose_human} pull)
	@${compose} pull

.PHONY: start
ifndef network
start: network := ${compose_project_name}
endif
start: _create-log-directory _clean-logs pull
ifneq (,${compose_services})
	@$(call system,${compose_human} up --detach)
ifeq (${env},$(filter ${env},test development))
	@${compose} up --detach --force-recreate --renew-anon-volumes --remove-orphans ${services} ${log} || ${exit_fail}
	@[ -n '${sidecar}' ] && \
         ( \
           $(call echo,(joining dependency network ${cyan}${network}${reset})) ; \
           $(call system,docker network connect "${network}") ; \
           docker network connect '${network}' '$(shell hostname)' ${log} \
           || ( \
           $(call warn,Unable to join network: "${cyan}${network}${reset}". Container will not be able to connect to dependency services) ; \
           $(call echo,Try deleting "${cyan}orchestration/.sidecar${reset}" if you do not want to use sidecar mode) ; \
           ) \
         ) \
         || ( [ -z '${sidecar}' ] || ${exit_fail} )
else
	@${compose} up --detach --scale app=$${instances:-1} ${log} || ${exit_fail}
endif
	@$(call echo,${env_human} containers started ${tick})
	@$(call echo,Waiting for services to become available)
	@$(call make,wait) 2>${stderr} || ${exit_fail}
endif

.PHONY: stop
stop: network := ${compose_project_name}
stop:
ifneq (,${compose_services})
	@$(call echo,Stopping ${env_human} containers)
	@$(call system,${compose_human} down)
	@if docker ps --format "{{.ID}}" | grep -q $(shell hostname) ; \
          then \
            ( docker network disconnect ${network} $(shell hostname) ${log} || : ) \
            && \
            ( ${compose} down ${log} || ${exit_fail} ) ; \
          else \
            ${compose} down ${log} || ${exit_fail} ; \
          fi
	@$(call echo,${env_human} containers stopped ${tick})
endif

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
                $(call echo,Environment${reset}: ${cyan}${env_file}${reset}) && \
                cat '${env_file}' | ${format_env} \
            ) ; \
        fi
	${rails} console

.PHONY: db-console
db-console:
	@${rake} orchestration:db:console RAILS_ENV=${env}

.PHONY: setup
ifneq (,$(wildcard config/database.yml))
setup: url := $(shell ${rake} orchestration:db:url RAILS_ENV=${env} 2>/dev/null)
endif
setup: _log-notify
	@$(call echo,Setting up ${env_human} environment)
	@$(call make,start env=${env})
ifneq (,$(wildcard config/database.yml))
	@$(call echo,Preparing ${env_human} database)
	@$(call system,rake db:create RAILS_ENV="${env}")
	@${rake} db:create RAILS_ENV=${env} DATABASE_URL='${url}' ${log} || : ${log}
  ifneq (,$(wildcard db/structure.sql))
	@$(call system,rake db:structure:load RAILS_ENV="${env}" ${url_prefix}DATABASE_URL="${url}")
	@${rake} db:structure:load RAILS_ENV="${env}" DATABASE_URL='${url}' ${log} || ${exit_fail}
  else ifneq (,$(wildcard db/schema.rb))
	@$(call system,rake db:schema:load RAILS_ENV="${env}" ${url_prefix}DATABASE_URL="${url}")
	@${rake} db:schema:load RAILS_ENV="${env}" DATABASE_URL='${url}' ${log} || ${exit_fail}
  endif
	@$(call system,rake db:migrate RAILS_ENV="${env}" ${url_prefix}DATABASE_URL="${url}")
	@${rake} db:migrate RAILS_ENV="${env}" DATABASE_URL='${url}' ${log} || ${exit_fail}
endif
	@if $(MAKE) -n post-setup >/dev/null 2>&1; then \
          $(call system,make post-setup RAILS_ENV="${env}") \
          && $(MAKE) post-setup RAILS_ENV=${env}; fi
	@$(call echo,${env_human} environment setup complete ${tick})

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
ifneq (build,${src_cmd})
ifneq (push,${src_cmd})
	@echo ; \
        $(call hr,${yellow}) ; \
        $(call println,'${gray}docker-compose logs${reset}') ; \
        $(call hr,${yellow}) ; \
        echo
	@${compose} logs
	@echo ; \
        $(call hr,${yellow})
	@$(NOOP)
endif
endif

.PHONY: tag
tag:
	@echo ${docker_image}

### Deployment utility commands ###

.PHONY: deploy
deploy: _log-notify _clean-logs
ifdef env_file
deploy: env_file_option = --env-file ${env_file}
endif
deploy: RAILS_ENV := ${env}
deploy: RACK_ENV := ${env}
deploy: DOCKER_TAG = ${git_version}
deploy: base_vars = DOCKER_ORGANIZATION=${docker_organization} DOCKER_REPOSITORY=${docker_repository} DOCKER_TAG=${git_version}
deploy: compose_deploy := ${base_vars} COMPOSE_PROJECT_NAME=${project_base} HOST_UID=$(shell id -u) docker-compose ${env_file_option} --project-name ${project_base} -f orchestration/docker-compose.deployment.yml
deploy: config_cmd = ${compose_deploy} config
deploy: remote_cmd = cat | docker stack deploy --prune --with-registry-auth -c - ${project_base}
deploy: ssh_cmd = ssh "${manager}"
deploy: deploy_cmd := ${config_cmd} | ${ssh_cmd} "/bin/bash -lc '${remote_cmd}'"
deploy:
ifndef manager
	@$(call fail,Missing ${cyan}manager${reset} parameter: ${cyan}make deploy manager=swarm-manager.example.com${reset}) ; exit 1
endif
	@$(call echo,Deploying ${env_human} stack via ${cyan}${manager}${reset} as ${cyan}${project_base}${reset}) && \
          ( \
             ( test -f '${env_file}' && $(call echo,Deployment environment:) && cat '${env_file}' | ${format_env} || : ) && \
             $(call echo,Application image: ${cyan}${docker_image}${reset}) ; \
	     $(call system,${config_cmd} | ${ssh_cmd} "/bin/bash -lc '\''${remote_cmd}'\''") ; \
	     ${deploy_cmd} \
          )
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
	@ssh "${manager}" 'docker service rollback --detach "${compose_project_name}_${service}"' ${log} || ${exit_fail}
	@$(call echo,Rollback request ${green}complete${reset} ${tick})

### Service healthcheck commands ###

.PHONY: wait
wait:
	@${rake} orchestration:wait
	@$(call echo,${env_human} services ${green}ready${reset} ${tick})

## Generic Listener healthcheck for TCP services ##

wait-listener:
	@${rake} orchestration:listener:wait service=${service} sidecar=${sidecar}

### Docker build commands ###

.PHONY: build
build: _log-notify _clean-logs
build: build_dir = ${orchestration_dir}/.build
build: context = ${build_dir}/context.tar
build: build_args := --build-arg GIT_COMMIT='${git_version}' $(shell grep '^ARG ' orchestration/Dockerfile | sed -e 's/=.*$$//' -e 's/^ARG /--build-arg /')
build: tag_human = ${cyan}${docker_organization}/${docker_repository}:${git_version}${reset}
build: latest_tag_human = ${cyan}${docker_organization}/${docker_repository}:latest${reset}
build: _create-log-directory check-local-changes
	@$(call echo,Preparing build context from ${cyan}${git_branch}${reset} (${cyan}${git_version}${reset})${reset})
	@$(call system,git archive --format "tar" -o "${context}" "${git_branch}")
	@mkdir -p ${orchestration_dir}/.build ${log} || ${exit_fail}
	@cp '$(shell bundle info --path orchestration)/lib/orchestration/healthcheck.bash' '${orchestration_dir}/healthcheck'
	@chmod +x '${orchestration_dir}/healthcheck'
ifndef dev
	@git show ${git_branch}:./Gemfile > ${orchestration_dir}/.build/Gemfile 2>${stderr} || ${exit_fail}
	@git show ${git_branch}:./Gemfile.lock > ${orchestration_dir}/.build/Gemfile.lock 2>${stderr} || ${exit_fail}
	@git archive --format 'tar' -o '${context}' '${git_branch}' ${log} || ${exit_fail}
else
	@tar -cvf '${context}' . ${log} || ${exit_fail}
endif
	@tar --append --file '${context}' '${orchestration_dir}/healthcheck'
	@rm '${orchestration_dir}/healthcheck'
ifdef include
	@$(call echo,Including files from: ${cyan}${include}${reset})
	@(while read line; do \
            export line; \
            include_dir="${build_dir}/$$(dirname "$${line}")/" && \
            mkdir -p "$${include_dir}" && cp "$${line}" "$${include_dir}" \
            && (cd '${orchestration_dir}/.build/' && tar rf 'context.tar' "$${line}"); \
	    echo "${system_prefix}" "tar rf 'context.tar' '$${line}'"; \
          done < '${include}') ${log} || ${exit_fail}
	@$(call echo,Build context ${green}ready${reset} ${tick})
endif
	@$(call echo,Building image ${tag_human})
	@$(call system,docker build ${build_args} -t ${docker_organization}/${docker_repository}:${git_version} ${orchestration_dir}/)
	@docker build ${build_args} \
                        -t ${docker_organization}/${docker_repository}:${git_version} \
                        ${orchestration_dir}/ ${log_progress} || ${exit_fail}
	@echo
	@$(call echo,Build ${green}complete${reset} ${tick})
	@$(call echo,[${green}tag${reset}] ${tag_human})

.PHONY: push
push: _log-notify _clean-logs
	@$(call echo,Pushing ${cyan}${docker_image}${reset} to registry)
	@$(call system,docker push ${docker_image})
	@docker push ${docker_image} ${log_progress} || ${exit_fail}
	@echo
	@$(call echo,Push ${green}complete${reset} ${tick})

.PHONY: check-local-changes
check-local-changes:
ifndef dev
	@changes="$$(git status --porcelain)"; if ! [ -z "${changes}" ] && [[ "${changes}" != "?? orchestration/.sidecar" ]]; \
         then \
           $(call warn,You have uncommitted changes which will not be included in your build:) ; \
           git status --porcelain ; \
           $(call echo,Commit these changes to Git or, alternatively, build in development mode to test your changes before committing: ${cyan}make build dev=1${reset}) ; \
         fi
endif

### Internal Commands ###
#
.PHONY: _log-notify
_log-notify: comma=,
_log-notify: _verify-repository
ifndef verbose
	@$(call logs,${green}stdout${reset}: ${cyan}log/orchestration.stdout.log${reset}${comma} ${red}stderr${reset}: ${cyan}log/orchestration.stderr.log)
endif

.PHONY: _verify-repository
_verify-repository:
	@if ! git rev-parse HEAD >/dev/null 2>&1 ; then $(call fail,You must make at least one commit before you can use Orchestration commands) ; exit 1 ; fi

.PHONY: _clean-logs
_clean-logs:
_clean-logs: _create-log-directory
	@rm -f '${stdout}' '${stderr}'
	@touch '${stdout}' '${stderr}'

.PHONY: _create-log-directory
_create-log-directory:
	@mkdir -p log

# Used by Orchestration test suite to verify Makefile syntax
.PHONY: _test
_test:
	@echo 'test command'
