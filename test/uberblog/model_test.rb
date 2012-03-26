require 'uberblog/model'

module Uberblog

  module UnitTests

    module Model

      class RatingTest < Test::Unit::TestCase

        def test_must_count_and_calc_average
          rating = Uberblog::Model::Rating.new('post-id')
          assert_equal 0, rating.count
          assert_equal 0, rating.sum
          assert_equal 0, rating.average

          rating.add 5
          assert_equal 1, rating.count
          assert_equal 5, rating.sum
          assert_equal 5, rating.average

          rating.add 3
          assert_equal 2, rating.count
          assert_equal 8, rating.sum
          assert_equal 4, rating.average

          rating = Uberblog::Model::Rating.new('post-id', 16, 4)
          assert_equal 4, rating.count
          assert_equal 16, rating.sum
          assert_equal 4, rating.average

          rating.add 2
          assert_equal 5, rating.count
          assert_equal 18, rating.sum
          assert_equal 4, rating.average
        end

      end

    end

  end

end
