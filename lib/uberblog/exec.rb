require 'erb'
require 'rss/maker'
require 'find'
require 'pathname'
require 'yaml'
require 'optparse'
require 'twitter'
require 'bitly'
require 'uberblog/blog'
require 'uberblog/sitemap'

module Uberblog

  class Generic
    def initialize(baseDir, args)
      @baseDir, @args, @options = baseDir, args, {}
    end

    def execute
      @opts = OptionParser.new(&method(:set_opts))
      @opts.parse!(@args)

      begin
        @config = load_config(@options[:config])
      rescue
        puts "Cant read config file '#{@options[:config]}'!"
        exit 1
      end
    end

    protected
    def set_opts(opts)
      opts.on('-c', '--config <FILE>', 'Config file to use.') do |file|
        @options[:config] = file.to_sym
      end

      opts.on('-v', '--verbose', 'Tell you more.') do
        @options[:verbose] = true
      end

      opts.on_tail('-?', '-h', '--help', 'Show this message.') do
        puts opts
        exit 0
      end
    end

    def load_config(filepath)
      File.open("#{Pathname.getwd}/#{filepath}") { |file| YAML.load(file) }
    end

    def be_verbose(message)
      puts message if @options[:verbose]
    end

  end

  class Create < Generic
    def execute
      super

      dataDir = Pathname.new(@baseDir + @config['dataDir']).realpath
      id  = 0
      now = Time.now

      while true
        filename = "#{dataDir}/%d-%02d-%02d_#{id}" % [now.year, now.month, now.day]
        filename << '_draft' if @options[:draft]
        filename << '.md'
        break unless File.exist? filename
        id += 1
      end

      File.open(filename, 'w') { |file| file.write("## #{@options[:title]}") }
      filename = Pathname.new(filename).realpath.to_s
      puts "Created blog post #{filename}"
      exit 0
    end

    protected
    def set_opts(opts)
      super

      opts.banner = 'Usage: create -c <file> -t "The Blog Title" [-h]'

      opts.on('-t', '--title TITLE', 'Title of the blog post.') do |title|
        @options[:title] = title.to_sym
      end

      opts.on('-d', '--draft', 'Will mark the file name as draft') do
        @options[:draft] = true
      end
    end
  end

end
