require 'optparse'
require 'yaml'
require 'uberblog/config'
require 'uberblog/publisher'

module Uberblog

  # Module for CLI commands.
  module Cli

    # Mixin to load YAML configuration from file.
    module ConfigLoader

      def load_config(file, baseDir)
        config = File.open(file) { |f| YAML.load(f) }
        Uberblog::Config.new(config, baseDir)
      end

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

    # Command to publish the blog.
    class Publish < Command
      include ConfigLoader

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

    # Command to create post or site drafts
    class Create < Command
      include ConfigLoader

      # @param baseDir [String]
      def initialize(baseDir)
        super(baseDir)
        @options[:title] = 'no title'
        @options[:draft] = false
      end

      protected

      def set_options(opts)
        super

        opts.banner = 'Usage: create -c <file> -t "The Blog Title. [required]" [-h]'

        opts.on('-c', '--config <FILE>', 'Config file to use.') do |file|
          begin
            @config = load_config("#{Pathname.getwd}/#{file}", @baseDir)
          rescue
            @logger.error("Can't read config file '#{file}'!")
            exit RET_CANT_READ_FILE
          end
        end

        opts.on('-t', '--title TITLE', 'Title of the blog post.') do |title|
          @options[:title] = title.to_sym
        end

        opts.on('-d', '--draft', 'Will mark the file name as draft') do
          @options[:draft] = true
        end

      end

      def run
        raise OptionParser::MissingArgument, "Give at least the config file." if @config.nil?

        dataDir = Pathname.new(@baseDir + @config.dataDir).realpath.to_s

        if @options[:draft]
          dataDir << '/drafts'
        else
          dataDir<< '/posts'
        end

        id  = 0
        now = Time.now

        while true
          filename = dataDir + '/'
          filename << "%d-%02d-%02d" % [now.year, now.month, now.day]
          filename << "_#{id}.md"
          break unless File.exist? filename
          id += 1
        end

        File.open(filename, 'w') { |file| file.write("## #{@options[:title]}") }
        filename = Pathname.new(filename).realpath.to_s
        puts "Created blog post #{filename}"

        RET_OK
      end
    end

    # Command to install the blog
    #
    # - Create tables in SQLite database.
    class Install < Command

      protected

      def run
        require 'data_mapper'
        require 'uberblog/model'

        dbFile = "#{@baseDir}/data/database.sqlite"

        unless File.readable?(dbFile)
          @logger.error("Can't read db file '#{dbFile}'!")
          exit RET_CANT_READ_FILE
        end

        be_verbose("Create db schema in '#{dbFile}'...")

        DataMapper::Logger.new(@logger.stdout, :debug)
        DataMapper.setup(:default, "sqlite://#{dbFile}")
        DataMapper.finalize
        DataMapper.auto_migrate!

        RET_OK
      end

    end

  end

end