require 'uberblog/cli/command'

module Uberblog

  module Cli

    # Command to create post or site drafts
    class Create < Command
      include Cli

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

        dataDir = Pathname.new(@config.dataDir).realpath.to_s

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

  end

end
