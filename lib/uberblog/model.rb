#require 'data_mapper'
require 'dm-core'
require 'kramdown'
require 'uri'
require 'pathname'

DataMapper::Property::String.length(255)

module Uberblog

  module Model

    def Model.create_date(filename)
      return nil if filename.index('_').nil?

      dateParts = filename[0, filename.index('_')].split(/-/)

      return nil if 3 != dateParts.size
      return nil if dateParts.any? { |part| part.nil? or part.to_i == 0}

      begin
        return Time.utc(dateParts[0], dateParts[1], dateParts[2])
      rescue
        return nil
      end
    end

    def Model.generate_slug_url(path)
      slug = path.downcase.gsub(/[^a-z0-9]/, '-').gsub(/-+/, '-')

      if 45 == slug[0]
        slug = slug[1, slug.size - 1]
      end

      if 45 == slug[slug.size - 1]
        slug = slug[0, slug.size - 1]
      end

      slug
    end

    class MarkdownData

      attr_reader :metadata, :basename

      def MarkdownData.is_key?(str)
        58 == str[str.size - 1] # Last character is :?
      end

      def MarkdownData.parse_meta_data(text)
        hash    = {}
        lastKey = nil
        text.split.each do |splitter|
          if MarkdownData.is_key?(splitter)
            lastKey = splitter[0, splitter.size - 1]
            hash[lastKey] = ''
          else
            break if lastKey.nil?

            hash[lastKey] += ' ' if hash[lastKey].size > 0
            hash[lastKey] += splitter
          end
        end
        hash
      end

      def MarkdownData.extract_meta_data(document)
        firstElement = document.root.children[0]
        return {} if firstElement.nil? or firstElement.type != :p
        return self.parse_meta_data(firstElement.children[0].value)
      end

      def MarkdownData.remove_meta_data(document)
        copy = document.dup
        copy.root.children.delete_at(0)
        copy
      end

      def initialize(filename)
        @basename = Pathname.new(filename).basename.to_s
        @document = File.open(filename, "rb") { |file| Kramdown::Document.new(file.read) }
        @metadata = MarkdownData.extract_meta_data(@document)
      end

      def to_html
        return @document.to_html if self.metadata.size == 0 # No metadata to remove.
        return MarkdownData.remove_meta_data(@document).to_html
      end

      def title
        return @title unless @title.nil?

        @title = ''
        @document.root.children.each do |child|
          @title = child.children[0].value if :header == child.type and 2 == child.options()[:level]
        end

        @title
      end
    end

    class BlogData < MarkdownData

      def date
        Model.create_date(@basename)
      end

      def <=>(other)
        date <=> other.date
      end

      def to_s
        "<BlogData: #{title}, #{date}>"
      end

    end

    class SiteData < MarkdownData

      def to_s
        "<SiteData: #{title}>"
      end

    end

    class BlogPostList

      def initialize()
        @posts  = Array.new
      end

      def add(aBlogPost)
        unless @posts.empty?
          @posts[0].nextPost = aBlogPost.url
          aBlogPost.prevPost = @posts[0].url
        end

        @posts.unshift(aBlogPost)
      end

      def posts
        @posts
      end

      def each(&blk)
        @posts.each(&blk)
      end

    end

    class Html
      attr_accessor :profileLinks, :otherLinks, :sites
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

      attr_reader :siteUrl, :features
      attr_accessor :prevPost, :nextPost, :config, :data

      def title
        @data.title
      end

      def content
        @data.to_html
      end

      def date
        @data.date
      end

      def config=(c)
        @siteUrl  = c.siteUrl
        @features = c.features
      end

      def <=> other
        self.date <=> other.date
      end

      def filename
        "#{Model.generate_slug_url(self.title)}.html"
      end

      def date_formatted
        self.date.strftime('%d.%m.%Y')
      end

      def url
        # @todo move 'posts/' into config
        @siteUrl + 'posts/' + filename
      end

      def to_s
        "<BlogPost: #{filename}, #{@date}>"
      end

    end

    class Site < Html
      attr_accessor :title, :content, :data

      def config=(c)
        @siteUrl  = c.siteUrl
      end

      def title
        @data.title
      end

      def content
        @data.to_html
      end

      def filename
        @data.basename.gsub(".md", ".html")
      end

      def url
        # @todo move 'sites/' into config
        @siteUrl + 'sites/' + filename
      end

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
        return 0 unless @count
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