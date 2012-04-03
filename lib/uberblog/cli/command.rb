require 'optparse'
require 'yaml'
require 'uberblog/config'

module Uberblog

  module Cli

    def load_config(file, baseDir)
      config = File.open(file) { |f| YAML.load(f) }
      Uberblog::Config.new(config, baseDir)
    end

    # Generic command object.
    #
    # To implement concrete command extend class and
    # implement the run method.
    #
    # Invocation on CLI:
    # cmd = MyCommand.new
    # cmd.exec ARGV
    class Command
      # Return codes.
      RET_OK = 0
      RET_INVALID_OPTION = 1
      RET_CANT_READ_FILE = 2

      attr_accessor :logger

      # Initialize options hash.
      def initialize(baseDir)
        @baseDir = baseDir
        @options = {:verbose => false}
      end

      # Executes the command.
      #
      # First parsing options and then invokes run method.
      # The method shutdown will be invoked on SystemExit Exception.
      def exec(args)
        begin
          @opts = OptionParser.new(&method(:set_options))
          @opts.parse!(args)
          exit run
        rescue SystemExit
          shutdown
        rescue OptionParser::InvalidOption, OptionParser::MissingArgument => exception
          errorMessage = exception.to_s + "\n\n"
          errorMessage << @opts.to_s + "\n"
          @logger.error(errorMessage)
          exit RET_INVALID_OPTION
        end
      end

      protected

      # Shut down hook called on SystemExit thrown by the run method or it's return.'
      def shutdown

      end

      # Default implementation which cares for -h and -v.
      def set_options(opts)
        opts.on('-v', '--verbose', 'Tell you more.') do
          @options[:verbose] = true
        end

        opts.on_tail('-?', '-h', '--help', 'Show this message.') do
          puts opts
          puts
          exit 0
        end
      end

      # Writes message to stdout if -v was given.
      def be_verbose(message)
        @logger.log(message) if @options[:verbose]
      end

      # Default implementation.
      def run
        puts "You should override run method."
        return RET_OK
      end

    end

  end

end
