
module Uberblog

  module Model

    class Rating
      attr_accessor :post, :ratingSum, :ratingCount, :average

      def initialize
        @changed = false
      end

      def changed?
        return @changed
      end

    end

  end

end