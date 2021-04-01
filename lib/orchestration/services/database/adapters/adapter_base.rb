# frozen_string_literal: true

module Orchestration
  module Services
    module Database
      module Adapters
        module AdapterBase
          attr_reader :config

          def initialize(config = nil)
            @config = config
          end

          def console_command
            I18n.t("orchestration.dbconsole.#{name}") % config.settings.transform_keys(&:to_sym)
          end
        end
      end
    end
  end
end
