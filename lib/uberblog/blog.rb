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

        def to_s
            "<BlogData: #{title}, #{date}>"
        end
    end

    class BlogPost
        include Uberblog
        include Comparable
        attr_reader :title, :date, :content, :siteUrl

        def initialize(title, content, date, siteUrl)
            @title, @content, @date, @siteUrl = title, content, date, siteUrl
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

        def to_s
            "<BlogPost: #{@title}, #{@date}>"
        end
    end

    class BlogPostList
        attr_reader :posts, :siteUrl

        def initialize(siteUrl)
            @posts, @siteUrl   = Array.new, siteUrl
        end

        def append(aBlogPost)
            @posts.push aBlogPost
            self
        end

        def get_binding
            binding
        end
    end

    class Layout
        attr_reader :siteUrl, :language
        attr_accessor :title, :headline, :description, :content

        def initialize(siteUrl, template, language)
            @siteUrl, @template, @language = siteUrl, template, language
            @title, @headline, @description, @content = 'n/a'
        end

        def to_html
            @template.result binding
        end
    end
end