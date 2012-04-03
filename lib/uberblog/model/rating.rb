require 'dm-core'

module Uberblog

  module Model

    class Rating
      include DataMapper::Resource

      DataMapper::Property::String.length(255)

      property :post,  String,  :key => true
      property :sum,   Integer, :required => true, :default => 0
      property :count, Integer, :required => true, :default => 0

      def average
        return 0 if @count == 0

        begin
          return ((@sum + 0.0) / @count).round
        rescue FloatDomainError
          return 0
        end
      end

      def add(rate)
        attribute_set :sum, rate + @sum
        attribute_set :count, @count + 1
      end

      def <=> other
        average <=> other.average
      end

      def == other
        post == other.post && average == other.average
      end

      def get_attributes
        {:post => @post, :sum => @sum, :count => @count, :average => average}
      end
    end

  end

end
