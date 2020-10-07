module Glueby
  module Contract
    class TokenGenerator < Rails::Generators::Base
      include ::Rails::Generators::Migration
      include Glueby::Generator::MigrateGenerator
      extend Glueby::Generator::MigrateGenerator::ClassMethod

      source_root File.expand_path('templates', __dir__)

      def create_migration_file
        migration_dir = File.expand_path("db/migrate")

        if self.class.migration_exists?(migration_dir, "create_token")
          ::Kernel.warn "Migration already exists: create_token"
        else
          migration_template(
            "token_table.rb.erb",
            "db/migrate/create_token.rb",
            migration_version: migration_version,
            table_options: table_options,
          )
        end

        if self.class.migration_exists?(migration_dir, "create_tx_issue")
          ::Kernel.warn "Migration already exists: create_tx_issue"
        else
          migration_template(
            "tx_issue_table.rb.erb",
            "db/migrate/create_tx_issue.rb",
            migration_version: migration_version,
            table_options: table_options,
          )
        end

        if self.class.migration_exists?(migration_dir, "create_tx_transfer")
          ::Kernel.warn "Migration already exists: create_tx_transfer"
        else
          migration_template(
            "tx_transfer_table.rb.erb",
            "db/migrate/create_tx_transfer.rb",
            migration_version: migration_version,
            table_options: table_options,
          )
        end

        if self.class.migration_exists?(migration_dir, "create_tx_burn")
          ::Kernel.warn "Migration already exists: create_tx_burn"
        else
          migration_template(
            "tx_burn_table.rb.erb",
            "db/migrate/create_tx_burn.rb",
            migration_version: migration_version,
            table_options: table_options,
          )
        end

        if self.class.migration_exists?(migration_dir, "create_tx_reissue")
          ::Kernel.warn "Migration already exists: create_tx_reissue"
        else
          migration_template(
            "tx_reissue_table.rb.erb",
            "db/migrate/create_tx_reissue.rb",
            migration_version: migration_version,
            table_options: table_options,
          )
        end

        if self.class.migration_exists?(migration_dir, "create_tx_payment")
          ::Kernel.warn "Migration already exists: create_tx_payment"
        else
          migration_template(
            "tx_payment_table.rb.erb",
            "db/migrate/create_tx_payment.rb",
            migration_version: migration_version,
            table_options: table_options,
          )
        end
      end
    end
  end
end
