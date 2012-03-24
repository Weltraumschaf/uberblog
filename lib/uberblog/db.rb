module Uberblog

  module Db

    class Table
      attr_reader :db, :name

      def initialize(name, dbFile = "test.db")
        @db   = SQLite3::Database.new(dbFile)
        @name = extract_table_name(name )
      end

      def self.extract_table_name(className)
        className.sub!(/Table/, '').downcase
      end

    end

    class RatingsTable < Table

      def initialize(name, dbFile = "test.db")
        super(self.class, dbFile)
      end

      def create
        db.execute <<-SQL
          create table name (
            post        varchar(500), # host agnostic URI /foo/bar-baz.html eg.
            ratingSum   int,
            ratingCount int,
            average     int           # ratingSum / ratingCount
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

      def find_by_post(post)

      end

      def create(rating)

      end

      def update(rating)

      end

      def delete(rating)

      end

    end

  end
end