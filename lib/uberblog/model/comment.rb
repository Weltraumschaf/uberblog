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

  end

end