require 'erb'
require 'rss/maker'
require 'find'
require 'pathname'
require 'yaml'
require 'optparse'
require 'uberblog/blog'
require 'uberblog/sitemap'

module Uberblog

    class Generic
        def initialize(baseDir, args)
            @baseDir = baseDir
            @args    = args
            @options = {}
        end

        def execute
            @opts = OptionParser.new(&method(:set_opts))
            @opts.parse!(@args)
        end

        protected
        def set_opts(opts)
            opts.on('-c', '--config <FILE>', 'Config file to use.') do |file|
                @options[:config] = file.to_sym
            end

            opts.on_tail('-?', '-h', '--help', 'Show this message.') do
                puts opts
                exit 0
            end
        end

        def load_config(filepath)
            File.open("#{Pathname.getwd}/#{filepath}") { |file| YAML.load(file) }
        end
    end

    class Create < Generic
        def execute
            super
            config   = load_config(@options[:config])
            dataDir  = @baseDir + config['dataDir']
            id       = 0
            now      = Time.now

            while true
                filename = "#{dataDir}/%d-%02d-%02d_#{id}.md" % [ now.year, now.month, now.day ]
                break unless File.exist? filename
                id += 1
            end

            File.open(filename, 'w') { |file| file.write("## #{@options[:title]}") }
            puts "Created blog post #{filename}"
            exit 0
        end

        protected
        def set_opts(opts)
            super
            opts.on('-t', '--title TITLE', 'Title of the blog post.') do |title|
                @options[:title] = title.to_sym
            end
        end
    end

    class Publisher < Generic

        def execute
            super
            puts 'Publishing the blog...'
            config       = load_config(@options[:config])
            @dataDir     = @baseDir + config['dataDir']
            @htdocs      = @baseDir + config['htdocs']
            @tplDir      = @baseDir + config['tplDir']
            @siteUrl     = config['siteUrl']
            @headline    = config['headline']
            @description = config['description']
            @language    = config['language']
            @list        = Uberblog::BlogPostList.new(config['siteUrl'])
            @layout      = Uberblog::Layout.new(config['siteUrl'], create_template("layout"), @language)
            @layout.headline    = config['headline']
            @layout.description = config['description']
            create_posts
            create_index
            create_feed
            create_site_map
            exit 0
        end

        protected

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
                maker.channel.language      = @language
                maker.channel.lastBuildDate = Time.now
                maker.items.do_sort         = true

                @list.posts.each do |post|
                    item = maker.items.new_item
                    item.title         = post.title
                    item.link          = post.filename
                    item.description   = post.content
                    item.date          = Time.parse(post.date_formatted)
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
            File.open("#{@htdocs}/sitemap.xml","w") { |f| f.write(site_map.to_xml) }
        end
    end
end