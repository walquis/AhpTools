module AhpTools

  module Commands

    class Base

      include_class "com.urbancode.anthill3.main.client.AnthillClient"

      def initialize(options)
        @options = options
        @anthill = connect
      end

      def connect
        begin
          AnthillClient::connect(CONFIG[:host_name], CONFIG[:host_port], CONFIG[:username], CONFIG[:password])
        rescue Exception => e
          error "Could not connect to anthillpro at #{CONFIG[:host_name]}:#{CONFIG[:host_port]} with user #{CONFIG[:username]}", e
        end
      end

      def authenticated_uow(&block)
        # info "starting transaction"
        uow = @anthill.create_unit_of_work
        yield uow
        # info "committing transaction"
        uow.commit_and_close
      end

      def info(message)
        $stdout.puts "info: " + message unless @options[:quiet]
      end

      def error(message, exception=nil)
        $stderr.puts message
        $stderr.puts ""
        $stderr.puts "Details:"
        $stderr.puts exception unless exception.nil?
      end

    end

  end
end
