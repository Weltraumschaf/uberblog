require 'sqlite3'

module Uberblog

  module Db

    class Table
      attr_reader :db, :name

      def initialize(name, dbFile = "test.db")
        @db   = SQLite3::Database.new(dbFile)
        @name = Table.extract_table_name(name )
      end

      def self.extract_table_name(className)
        className.sub!(/Table/, '').downcase
      end

    end

    class RatingsTable < Table

      def initialize(dbFile = "test.db")
        super(self.class.to_s, dbFile)
      end

      def create_repo
        return RatingRepo.new(db, name)
      end

      def create
        db.execute <<-SQL
          create table name (
            post     varchar(500), # host agnostic URI /foo/bar-baz.html eg.
            sum      int,
            count    int,
          );
        SQL
      end

      def truncate
        db.execute <<-SQL
          truncate table name
        SQL
      end

      def drop
        db.execute <<-SQL
          drop table name
        SQL
      end
    end

    class RatingRepo

      def initialize(name, db)
        @db   = db
        @name = name
      end

      def find_by_post(post)
        @db.execute "select * from #{name} where post = '?'", post do |row|

        end
      end

      def create(rating)
        @db.execute "insert into #{name} values (?, ?, ?, ?)", rating.post, rating.sum, rating.count, rating.average
      end

      def update(rating)

      end

      def delete(rating)
        @db.execute "delete from #{name} where post = '?'", rating.post
      end

    end

  end
end