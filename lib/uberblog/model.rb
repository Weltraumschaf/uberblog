require 'data_mapper'
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

      def initialize(filename)
        @basename = Pathname.new(filename).basename.to_s
        @document = File.open(filename, "rb") { |file| Kramdown::Document.new(file.read) }
      end

      def to_html
        @document.to_html
      end

      def extract_meta_data
        puts @document.inspect
      end
    end

    class BlogData < MarkdownData

      def title
        @document.root.children[0].children[0].value
      end

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

      def get_binding
        binding
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

      attr_reader :title, :date, :content, :siteUrl, :features
      attr_accessor :title, :content, :prevPost, :nextPost, :data, :config

      def data=(d)
        @title, @content, @date = d.title, d.to_html, d.date
      end

      def config=(c)
        @siteUrl  = c.siteUrl
        @features = c.features
      end

      def <=> other
        self.date <=> other.date
      end

      def filename
        "#{Model.generate_slug_url(@title)}.html"
      end

      def date_formatted
        @date.strftime('%d.%m.%Y')
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