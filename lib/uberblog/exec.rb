require 'erb'
require 'rss/maker'
require 'find'
require 'pathname'
require 'yaml'
require 'uberblog/blog'
require 'uberblog/sitemap'

module Uberblog
    class Publisher
        def initialize(baseDir, args)
            config = File.open("#{baseDir}/config/blog.yml") { |file| YAML.load(file) }
            @dataDir     = baseDir + config['dataDir']
            @htdocs      = baseDir + config['htdocs']
            @tplDir      = baseDir + config['tplDir']
            @siteUrl     = config['siteUrl']
            @headline    = config['headline']
            @description = config['description']
            @list        = Uberblog::BlogPostList.new(config['siteUrl'])
            @layout      = Uberblog::Layout.new(config['siteUrl'], create_template("layout"))
            @layout.headline    = config['headline']
            @layout.description = config['description']
        end

        def create_template(name)
            File.open("#{@tplDir}/#{name}.erb", "rb") { |file| ERB.new(file.read) }
        end

        def create_posts
            template = create_template("post")
            Dir.foreach(@dataDir) do |file|
                next if file == '.' or file == '..'
                data = Uberblog::BlogData.new("#{@dataDir}/#{file}")
                post = Uberblog::BlogPost.new(data.title, data.to_html, data.date, @siteUrl)
                @layout.title   = "#{@headline} | #{data.title}"
                @layout.content = template.result(post.get_binding)
                File.open("#{@htdocs}/#{post.filename}", 'w') { |file| file.write(@layout.to_html) }
                @list.append(post)
            end
        end

        def create_index
            @layout.title   = "#{@headline} | Blog"
            template        = create_template("index")
            @layout.content = template.result(@list.get_binding)
            File.open("#{@htdocs}/index.html", 'w') { |file| file.write(@layout.to_html) }
        end

        def create_feed
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

        def create_site_map
            site_map  = Uberblog::SiteMap.new(@siteUrl, create_template("site_map"))
            Find.find(@htdocs) do |file|
                if file =~ /.html$/
                    site_map.append(file)
                end
            end
            File.open("#{@htdocs}/site_map.xml","w") { |f| f.write(site_map.to_xml) }
        end

        def execute
            puts 'Publishing the blog...'
            create_posts
            create_index
            create_feed
            create_site_map
            exit 0
        end
    end
end