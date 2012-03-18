require 'uberblog'
require 'erb'
require 'rss/maker'
require 'find'
require 'pathname'

# config stuff
$headline    = 'Das Weltraumschaf'
$description = 'The Music Making Space Animal'
$siteUrl     = 'http://localhost/~sxs/uberblog/'
$baseDir     = Pathname.pwd.to_s
$dataDir     = "#{$baseDir}/data"
$tplDir      = "#{$baseDir}/templates"
$htdocs      = "#{$baseDir}/htdocs"

template = File.open("#{$tplDir}/layout.erb", "rb") { |file| ERB.new(file.read) }
layout = Uberblog::Layout.new($siteUrl, template)
layout.headline = $headline
layout.description = $description

# crate the blog posts
template = File.open("#{$tplDir}/post.erb", "rb") { |file| file.read }
rhtml    = ERB.new(template)
list     = Uberblog::BlogPostList.new($siteUrl)

Dir.foreach($dataDir) do |file|
    next if file == '.' or file == '..'
    data = Uberblog::BlogData.new("#{$dataDir}/#{file}")
    post = Uberblog::BlogPost.new(data.title, data.html, data.date, $siteUrl)
    layout.title   = "#{$headline} | #{data.title}"
    layout.content = rhtml.result(post.getBinding)
    File.open("#{$htdocs}/#{post.filename}", 'w') { |file| file.write(layout.to_html) }
    list.append(post)
end

#create the index
template = File.open("#{$tplDir}/index.erb", "rb") { |file| file.read }
rhtml    = ERB.new(template)
layout.title   = "#{$headline} | Blog"
layout.content = rhtml.result(list.getBinding)
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
template = File.open("#{$tplDir}/sitemap.erb", "rb") { |file| file.read }
rhtml    = ERB.new(template)
sitemap  = Uberblog::SiteMap.new($siteUrl)
Find.find($htdocs) do |file|
    if file =~ /.html$/
        sitemap.append(file)
    end
end
xml = rhtml.result(sitemap.getBinding)
File.open("#{$htdocs}/sitemap.xml","w") { |f| f.write(xml) }