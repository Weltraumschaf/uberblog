require 'dm-core'

module Uberblog

  module Model

    class Comment
      include DataMapper::Resource

      DataMapper::Property::String.length(255)

      property :post,  String, :key => true
      property :text,  Text,   :required => true
      property :name,  String, :default => 'anonymous'
      property :url,   String, :default => ''
    end

    def get_attributes
      { :post => @post, :text => @text, :name => @name, :url => @url }
    end

  end

end