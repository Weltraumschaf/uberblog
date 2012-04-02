require 'dm-core'

module Uberblog

  module Model

    class Comment
      include DataMapper::Resource

      DataMapper::Property::String.length(255)

      property :id,    Serial, :key => true
      property :post,  String, :required => true
      property :text,  Text,   :required => true
      property :name,  String, :default => 'anonymous'
      property :url,   String, :default => ''
    end

    def get_attributes
      {:id => @id, :post => @post, :text => @text, :name => @name, :url => @url}
    end

  end

end