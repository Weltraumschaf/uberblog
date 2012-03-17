require 'erb'
require 'kramdown'
require 'uri'
require 'pathname'

class BlogPost
    def initialize(title, content, date)
        @title = title
        @content = content
        @date = date
    end

    def getBinding
        binding
    end

    def generateFilename
        URI.escape "#{@title.gsub(' ', '-').gsub('/', '%2F')}.html"
    end

    def to_s
        "<BlogPost: #{@title}>"
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
        datePart = basename[0, basename.index('_')]
    end

    def to_s
        "<BlogData: #{title}>"
    end
end

template = File.open("./template.rhtml", "rb") { |file| file.read }
rhtml = ERB.new(template)

Dir.foreach("./data") do |file|
    next if file == '.' or file == '..'
    data = BlogData.new("./data/#{file}")
    post = BlogPost.new(data.title, data.html, data.date)
    generated = File.new("./htdocs/#{post.generateFilename}", 'w')
    generated.write rhtml.result(post.getBinding)
    generated.close
end