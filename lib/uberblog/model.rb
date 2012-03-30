require 'data_mapper'

DataMapper::Property::String.length(255)

module Uberblog

  module Model
    attr_accessor :profileLinks, :otherLinks, :sites

    class Html
      attr_reader :template, :layout

      def initialize(template, layout)
        @template = template
        @layout   = layout
      end

      def to_html
        @layout.content = @template.result binding
        @layout.to_html
      end
    end

    class Layout

      attr_reader :siteUrl, :language, :template
      attr_accessor :title, :headline, :description, :content, :apiUrl

      def initialize(template, siteUrl, language = 'en')
        @template, @siteUrl, @language = template, siteUrl, language
        @title       = 'n/a'
        @headline    = 'n/a'
        @description = 'n/a'
        @content     = 'n/a'
        @apiUrl      = ''
        @profileLinks = []
        @otherLinks   = []
        @sites        = []
      end

      def to_html
        @template.result binding
      end
    end

    class Index < Html
      attr_accessor :posts

      def initialize(template, layout)
        super(template, layout)
        @posts = []
      end

    end

    class BlogPost < Html
      attr_accessor :title, :content

      def initialize(template, layout)
        super(template, layout)
      end

    end

    class Site < Html
      attr_accessor :title, :content
    end

    class Link
      attr_accessor :uri, :text
    end

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
        attribute_set :sum, rate + @sum
        attribute_set :count, @count + 1
      end

      def <=> other
        average <=> other.average
      end

      def == other
        post == other.post && average == other.average
      end

      def hash
        {:post => @post, :sum => @sum, :count => @count, :average => average}
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