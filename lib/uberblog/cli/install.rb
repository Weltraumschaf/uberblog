require 'data_mapper'
require 'uberblog/cli/command'
require 'uberblog/model/rating'
require 'uberblog/model/comment'

module Uberblog

  module Cli

    # Command to install the blog
    #
    # - Create tables in SQLite database.
    class Install < Command

      protected

      def run
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
