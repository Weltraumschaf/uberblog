require 'uberblog/blog'
require 'uberblog/sitemap'
require 'erb'
require 'rss/maker'
require 'find'
require 'pathname'

module Uberblog
    class Publisher
        def initialize(config)
            @dataDir     = config['baseDir'] + config['dataDir']
            @htdocs      = config['baseDir'] + config['htdocs']
            @tplDir      = config['baseDir'] + config['tplDir']
            @siteUrl     = config['siteUrl']
            @headline    = config['headline']
            @description = config['description']
            @list        = Uberblog::BlogPostList.new(config['siteUrl'])
            @layout      = Uberblog::Layout.new(config['siteUrl'], createTemplate("layout"))
            @layout.headline    = config['headline']
            @layout.description = config['description']
        end

        def createTemplate(name)
            File.open("#{@tplDir}/#{name}.erb", "rb") { |file| ERB.new(file.read) }
        end

        def createPosts
            template = createTemplate("post")
            Dir.foreach(@dataDir) do |file|
                next if file == '.' or file == '..'
                data = Uberblog::BlogData.new("#{@dataDir}/#{file}")
                post = Uberblog::BlogPost.new(data.title, data.html, data.date, @siteUrl)
                @layout.title   = "#{@headline} | #{data.title}"
                @layout.content = template.result(post.getBinding)
                File.open("#{@htdocs}/#{post.filename}", 'w') { |file| file.write(@layout.to_html) }
                @list.append(post)
            end
        end

        def createIndex
            template = createTemplate("index")
            @layout.title   = "#{@headline} | Blog"
            @layout.content = template.result(@list.getBinding)
            File.open("#{@htdocs}/index.html", 'w') { |file| file.write(@layout.to_html) }
        end

        def createFeed
            feed = RSS::Maker.make('2.0') do |maker|
                maker.channel.title         = @headline
                maker.channel.link          = "#{@siteUrl}feed.xml"
                maker.channel.description   = @description
                maker.channel.language      = 'en'
                maker.channel.lastBuildDate = Time.now
                maker.items.do_sort         = true

                @list.posts.each do |post|
                    item = maker.items.new_item
                    item.title         = post.title
                    item.link          = post.filename
                    item.description   = post.content
                    item.date          = Time.parse(post.date)
                end
            end
            File.open("#{@htdocs}/feed.xml","w") { |file| file.write(feed) }
        end

        def createSiteMap
            sitemap  = Uberblog::SiteMap.new(@siteUrl, createTemplate("sitemap"))
            Find.find(@htdocs) do |file|
                if file =~ /.html$/
                    sitemap.append(file)
                end
            end
            File.open("#{@htdocs}/sitemap.xml","w") { |f| f.write(sitemap.to_xml) }
        end

        def execute
            puts 'Publishing the blog...'
            createPosts
            createIndex
            createFeed
            createSiteMap
            exit 0
        end
    end
end