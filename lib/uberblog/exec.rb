require 'uberblog/blog'
require 'uberblog/sitemap'
require 'erb'
require 'rss/maker'
require 'find'
require 'pathname'

$headline    = 'Das Weltraumschaf'
$description = 'The Music Making Space Animal'
$siteUrl     = 'http://localhost/~sxs/uberblog/'
$baseDir     = '/Users/sxs/src/ruby/uberblog'
$dataDir     = "#{$baseDir}/data"
$tplDir      = "#{$baseDir}/templates"
$htdocs      = "#{$baseDir}/htdocs"

module Uberblog
    class Publisher
        def initialize

        end

        def createTemplate(name)
            File.open("#{$tplDir}/#{name}.erb", "rb") { |file| ERB.new(file.read) }
        end

        def execute
            puts 'Publishing the blog...'
            template = createTemplate("layout")
            layout   = Uberblog::Layout.new($siteUrl, template)
            layout.headline    = $headline
            layout.description = $description

# crate the blog posts
            template = createTemplate("post")
            list     = Uberblog::BlogPostList.new($siteUrl)

            Dir.foreach($dataDir) do |file|
                next if file == '.' or file == '..'
                data = Uberblog::BlogData.new("#{$dataDir}/#{file}")
                post = Uberblog::BlogPost.new(data.title, data.html, data.date, $siteUrl)
                layout.title   = "#{$headline} | #{data.title}"
                layout.content = template.result(post.getBinding)
                File.open("#{$htdocs}/#{post.filename}", 'w') { |file| file.write(layout.to_html) }
                list.append(post)
            end

#create the index
            template = createTemplate("index")
            layout.title   = "#{$headline} | Blog"
            layout.content = template.result(list.getBinding)
            File.open("#{$htdocs}/index.html", 'w') { |file| file.write(layout.to_html) }

#create the feeds
            feed = RSS::Maker.make('2.0') do |maker|
                maker.channel.title         = 'Das Weltraumschaf'
                maker.channel.link          = "#{$siteUrl}feed.xml"
                maker.channel.description   = 'The Music Making Space Animal'
                maker.channel.language      = 'en'
                maker.channel.lastBuildDate = Time.now
                maker.items.do_sort         = true

                list.posts.each do |post|
                    item = maker.items.new_item
                    item.title         = post.title
                    item.link          = post.filename
                    item.description   = post.content
                    item.date          = Time.parse(post.date)
                end
            end
            File.open("#{$htdocs}/feed.xml","w") { |file| file.write(feed) }

#create the google site map
            sitemap  = Uberblog::SiteMap.new($siteUrl, createTemplate("sitemap"))
            Find.find($htdocs) do |file|
                if file =~ /.html$/
                    sitemap.append(file)
                end
            end
            File.open("#{$htdocs}/sitemap.xml","w") { |f| f.write(sitemap.to_xml) }
            exit 0
        end
    end
end