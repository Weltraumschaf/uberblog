require 'data_mapper'

DataMapper::Property::String.length(255)

module Uberblog

  module Model

    class Rating
      include DataMapper::Resource

      property :post,  String,  :key => true
      property :sum,   Integer, :required => true, :default => 0
      property :count, Integer, :required => true, :default => 0

      def average
        return 0 if 0 == @count
        return ((@sum + 0.0) / @count).round
      end

      def add(rate)
        attributes = {
          :sum   => sum + rate,
          :count => count + 1
        }
      end

      def <=> other
        average <=> other.average
      end

      def == other
        post == other.post && average == other.average
      end

    end

    class Comment
      include DataMapper::Resource

      property :post,  String, :key => true
      property :text,  Text,   :required => true
      property :name,  String, :default => 'anonymous'
      property :url,   String, :default => ''
    end
  end

end