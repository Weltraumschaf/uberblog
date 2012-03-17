require 'kramdown'
require 'uri'
require 'pathname'

module Uberblog
    class BlogPost
        attr_reader :title, :date

        def initialize(title, content, date)
            @title = title
            @content = content
            @date = date
        end

        def getBinding
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
        def initialize
            @posts = Array.new
        end

        def append(aBlogPost)
            @posts.push(aBlogPost)
            self
        end

        def getBinding
            binding
        end
    end

    class BlogData
        def initialize(filename)
            @filename = filename
            content = File.open(filename, "rb") { |file| file.read }
            @doc = Kramdown::Document.new(content)
        end

        def title
            @doc.root.children[0].children[0].value
        end

        def html
            @doc.to_html
        end

        def date
            basename = Pathname.new(@filename).basename.to_s
            dateParts = basename[0, basename.index('_')].split(/-/)
            date = Time.utc(dateParts[0], dateParts[1], dateParts[2])
            date.strftime('%d.%m.%Y')
        end

        def to_s
            "<BlogData: #{title}>"
        end
    end
end