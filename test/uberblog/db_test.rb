require 'uberblog/db'

module Uberblog

  module UnitTests

    module Db

      class TableTest < Test::Unit::TestCase

        def test_must_extract_table_name
          assert_equal 'ratings', Uberblog::Db::Table.extract_table_name("RatingsTable")
          assert_equal 'foobar', Uberblog::Db::Table.extract_table_name("FooBarTable")
        end

      end

      class RatingTableTest < Test::Unit::TestCase

        def test_must_create_ratings_table
          add_failure ' not ready'
        end

        def test_must_truncate_ratings_table
          add_failure ' not ready'
        end

        def test_must_drop_ratings_table
          add_failure ' not ready'
        end

      end

      class RatingRepoTest < Test::Unit::TestCase

        def test_must_create_find_update_and_delete
          table = Uberblog::Db::RatingsTable.new
          repo  = table.create_repo
          post  = Uberblog::Model::Rating.new('post-id')
          add_failure ' not ready'
        end

      end

    end

  end

end