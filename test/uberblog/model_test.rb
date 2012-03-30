require 'uberblog/model'

module Uberblog

  module UnitTests

    module Model

      class ModuleTest < Test::Unit::TestCase

        must 'create date' do
          assert_equal Time.utc('2010', '03', '23'), Uberblog::Model.create_date('2010-03-23_1')
          assert_nil Uberblog::Model.create_date('foobar')
          assert_nil Uberblog::Model.create_date('foobar_1')
          assert_nil Uberblog::Model.create_date('2010-3_1')
          assert_nil Uberblog::Model.create_date('2010-33-45_0')
        end

        must 'generate slug url' do
          #assert_equal 'this-is-a-title', Uberblog::Model.generate_slug_url('This is A TITLE')
          assert_equal 'this-with-12-34-number-and-signgs', Uberblog::Model.generate_slug_url('-This with 12.34 number! and - signgs?')
        end

      end

      class RatingTest < Test::Unit::TestCase

        must 'count and calc average' do
          fail "not ready"
        end

      end

    end

  end

end
