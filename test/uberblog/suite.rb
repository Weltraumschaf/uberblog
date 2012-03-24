require 'test/unit/testsuite'
require 'uberblog/db_test'

module Uberblog

  module UnitTests

    class Suite < Test::Unit::TestSuite
      def self.suite
        result = self.new(self.class.name)
        result << Uberblog::UnitTests::Db::TableTest.suite
        result << Uberblog::UnitTests::Db::RatingTableTest.suite
        result << Uberblog::UnitTests::Db::RatingRepoTest.suite
        return result
      end

      def setup

      end

      def teardown

      end

      def run(*args)
        setup
        super
        teardown
      end
    end

  end

end