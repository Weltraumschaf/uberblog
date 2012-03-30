dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require 'rubygems'

module Uberblog

  # Default logger which loggs to STDOUT
  class Logger
    attr_reader :stdout, :stderr

    def initialize(stdout, stderr)
      @stdout = stdout
      @stdout = stderr
      @stdout = @stdout if @stdout.nil?
      @on     = true
    end

    def log(message)
      @stdout.puts message if @on
    end

    def error(message)
      @stderr.puts message
    end

    def on()
      @on = true
    end

    def off()
      @on = false
    end

  end

  class CliLogger < Logger

    def initialize
      super($stdout, $stderr)
    end

  end

  class FileLogger < Logger

    def initialize(stdoutFile, stderrFile)
      stdout = File.open(stdoutFile, 'rw')
      stderr = File.open(stderr, 'rw')
      super(stdout, stderr)
    end

  end

end