require 'uberblog/cli/command'
require 'uberblog/publisher'

module Uberblog

  module Cli

    # Command to publish the blog.
    class Publish < Command
      include Cli

      # @param baseDir [String]
      def initialize(baseDir)
        super(baseDir)
        @options = {
          :purge  => false,
          :quiet  => false,
          :sites  => false,
          :drafts => false
        }
      end

      protected

      def set_options(opts)
        super

        opts.banner = 'Usage: publish -c <file> [-p] [-h]'

        opts.on('-c', '--config <FILE>', 'Config file to use. [required]') do |file|
          begin
            @config = load_config("#{Pathname.getwd}/#{file}", @baseDir)
          rescue
            @logger.error("Can't read config file '#{file}'!")
            exit RET_CANT_READ_FILE
          end
        end

        opts.on('-p', '--purge', 'Regenerate all blog posts.') do
          @options[:purge] = true
        end

        opts.on('-q', '--quiet', 'Be quiet and dont post to social networks.') do
          @options[:quiet] = true
        end

        opts.on('-s', '--sites', 'Generate static sites.') do
          @options[:sites] = true
        end

        opts.on('-d', '--drafts', 'Publish drafts.') do
          @options[:drafts] = true
        end

      end

      def run
        raise OptionParser::MissingArgument, "Give at least the config file." if @config.nil?

        publisher = Uberblog::Publisher.new(@config)
        publisher.logger  = @logger
        publisher.verbose = @options[:verbose]
        publisher.purge   = @options[:purge]
        publisher.sites   = @options[:sites]
        publisher.quiet   = @options[:quiet]
        publisher.drafts  = @options[:drafts]
        publisher.source  = @config.dataDir
        publisher.target  = @config.htdocs
        publisher.publish
        RET_OK
      end
    end

  end

end
