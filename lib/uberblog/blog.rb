require 'kramdown'
require 'uri'
require 'pathname'

module Uberblog
    class BlogData
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
            dateParts = @basename[0, @basename.index('_')].split(/-/)
            date      = Time.utc(dateParts[0], dateParts[1], dateParts[2])
            date.strftime('%d.%m.%Y')
        end

        def to_s
            "<BlogData: #{title}, #{date}>"
        end
    end

    class BlogPost
        attr_reader :title, :date, :content, :siteUrl

        def initialize(title, content, date, siteUrl)
            @title      = title
            @content    = content
            @date       = date
            @siteUrl    = siteUrl
        end

        def get_binding
            binding
        end

        def filename
            "#{@title.downcase.gsub(/[^a-z0-9]/, '-')}.html"
        end

        def to_s
            "<BlogPost: #{@title}>"
        end
    end

    class BlogPostList
        attr_reader :posts, :siteUrl

        def initialize(siteUrl)
            @posts   = Array.new
            @siteUrl = siteUrl
        end

        def append(aBlogPost)
            @posts.push(aBlogPost)
            self
        end

        def get_binding
            binding
        end
    end

    class Layout
        attr_reader :siteUrl
        attr_accessor :title, :headline, :description, :content

        def initialize(siteUrl, template)
            @siteUrl     = siteUrl
            @template    = template
            @title       = 'no title'
            @headline    = 'no headline'
            @description = 'no description'
            @content     = 'no content'
        end

        def to_html
            @template.result(binding)
        end
    end
end