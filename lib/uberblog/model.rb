
module Uberblog

  module Model

    class Rating

      attr_reader :post, :sum, :count

      def initialize(post, sum = 0, count = 0)
        @post, @sum, @count = post, sum, count;
      end

      def average
        return 0 if 0 == @count
        return ((@sum + 0.0) / @count).round
      end

      def add(rate)
        @sum   += rate
        @count += 1
      end

      def <=> other
        average <=> other.average
      end

      def == other
        post == other.post && average == other.average
      end

    end

  end

end