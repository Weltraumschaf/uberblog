require 'test/unit/testsuite'
require 'test/unit'
require 'uberblog/model_test'

module Uberblog

  module UnitTests

    class Suite < Test::Unit::TestSuite
      def self.suite
        result = self.new(self.class.name)
        result << Uberblog::UnitTests::Model::ModuleTest.suite
        result << Uberblog::UnitTests::Model::RatingTest.suite
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