module Backup
  module Adapters
    class PostgreSQL < Backup::Adapters::Base

      attr_accessor :user, :password, :database, :skip_tables, :host, :port, :socket, :additional_options
      
      private

        # Dumps and Compresses the PostgreSQL file 
        def perform
            puts system_messages[:pgdump]; puts system_messages[:compressing]
           %x{ pg_dump -U #{user} #{options} #{additional_options} #{tables_to_skip} #{database} | gzip -f --best > #{File.join(tmp_path, compressed_file)} }
        end
        
        def performed_file_extension
          "sql"
        end

        # Loads the initial settings
        def load_settings
          %w(user password database skip_tables additional_options).each do |attribute|
            send(:"#{attribute}=", procedure.get_adapter_configuration.attributes[attribute])
          end
          
          %w(host port socket).each do |attribute|
            send(:"#{attribute}=", procedure.get_adapter_configuration.get_options.attributes[attribute])
          end
        end
        
        # Returns a list of options in PostgreSQL syntax
        def options
          options = String.new
          options += " --port='#{port}' "     unless port.blank?
          options += " --host='#{host}' "     unless host.blank?
          options += " --host='#{socket}' "   unless socket.blank?  unless options.include?('--host=')
          options
        end
        
        # Returns a list of tables to skip in PostgreSQL syntax
        def tables_to_skip
          return "" unless skip_tables
          [*skip_tables].map {|table| " -T \"#{table}\" "}
        end

    end
  end
end