require 'kramdown'
require 'uri'
require 'pathname'

module Uberblog

  def generate_slug_url(path)
    path.downcase.gsub(/[^a-z0-9]/, '-').gsub(/-+/, '-')
  end

  def create_date(filename)
    dateParts = filename[0, filename.index('_')].split(/-/)
    Time.utc(dateParts[0], dateParts[1], dateParts[2])
  end

  class BlogData
    include Uberblog

    def initialize(filename)
      @basename = Pathname.new(filename).basename.to_s
      @document = File.open(filename, "rb") { |file| Kramdown::Document.new(file.read) }
    end

    def title
      @document.root.children[0].children[0].value
    end

    def to_html
      @document.to_html
    end

    def date
      create_date(@basename)
    end

    def <=>(other)
      date <=> other.date
    end

    def to_s
      "<BlogData: #{title}, #{date}>"
    end
  end

  class BlogPost
    include Uberblog
    include Comparable
    attr_reader :title, :date, :content, :siteUrl, :features
    attr_accessor :prevPost, :nextPost

    def initialize(data, config)
      @title, @content, @date = data.title, data.to_html, data.date
      @siteUrl  = config.siteUrl
      @features = config.features
    end

    def <=> other
      self.date <=> other.date
    end

    def get_binding
      binding
    end

    def filename
      "#{generate_slug_url(@title)}.html"
    end

    def date_formatted
      @date.strftime('%d.%m.%Y')
    end

    def url
      # @todo move 'posts/' into config
      @siteUrl + 'posts/' + filename
    end

    def to_s
      str = "<BlogPost: #{filename}, #{@date}"

      if @prevPost or @nextPost
        str += " ("
      end

      if @prevPost
          str += "prev: #{@prevPost}"
      end

      if @nextPost
        if @prevPost
          str += ", "
        end

        str += "next: #{@nextPost}"
      end

      if @prevPost or @nextPost
        str += ")"
      end

      str += ">"
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

    def get_binding
      binding
    end
  end

  class Layout
    attr_reader :siteUrl, :language
    attr_accessor :title, :headline, :description, :content, :apiUrl

    def initialize(siteUrl, template, language)
      @siteUrl, @template, @language = siteUrl, template, language
      @title, @headline, @description, @content = 'n/a'
      @apiUrl = ''
    end

    def to_html
      @template.result binding
    end
  end
end