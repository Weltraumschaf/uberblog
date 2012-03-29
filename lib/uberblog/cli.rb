require 'optparse'
require 'yaml'
require 'uberblog/config'

module Uberblog

  # Module for CLI commands.
  module Cli

    # Mixin to load YAML configuration from file.
    module ConfigLoader

      def load_config(file)
        Uberblog::Config.new File.open(file) { |f| YAML.load(f) }
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

      # Initialize options hash.
      def initialize
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
          puts exception
          puts
          puts @opts
          puts
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
        puts message if @options[:verbose]
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
        @baseDir = baseDir
      end

      def set_options(opts)
        super

        opts.banner = 'Usage: publish -c <file> [-p] [-h]'

        opts.on('-c', '--config <FILE>', 'Config file to use.') do |file|
          @config = load_config "#{Pathname.getwd}/#{file}"
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

      end

      def run
        RET_OK
      end
    end

    # Command to create post or site drafts
    class Create < Command
      include ConfigLoader

      # @param baseDir [String]
      def initialize(baseDir)
        super()
        @baseDir = baseDir
        @options[:title] = 'no title'
        @options[:draft] = false
      end

      def set_options(opts)
        super

        opts.banner = 'Usage: create -c <file> -t "The Blog Title. [required]" [-h]'

        opts.on('-c', '--config <FILE>', 'Config file to use.') do |file|
          @config = load_config "#{Pathname.getwd}/#{file}"
        end

        opts.on('-t', '--title TITLE', 'Title of the blog post.') do |title|
          @options[:title] = title.to_sym
        end

        opts.on('-d', '--draft', 'Will mark the file name as draft') do
          @options[:draft] = true
        end

      end

      def run
        raise OptionParser::MissingArgument if @config.nil?
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

      # @param baseDir [String]
      def initialize(baseDir)
        @baseDir = baseDir
      end

      def run
        require 'data_mapper'
        require 'uberblog/model'

        DataMapper::Logger.new($stdout, :debug)
        DataMapper.setup(:default, "sqlite://#{@baseDir}/data/database.sqlite")
        DataMapper.finalize
        DataMapper.auto_migrate!

        RET_OK
      end

    end

  end

end