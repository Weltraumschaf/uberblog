require 'uberblog'
require 'erb'
require 'rss/maker'
require 'find'

$siteUrl = 'http://localhost/~sxs/uberblog/'

# crate the blog posts
template = File.open("./templates/post.rhtml", "rb") { |file| file.read }
rhtml    = ERB.new(template)
list     = Uberblog::BlogPostList.new($siteUrl)

Dir.foreach("./data") do |file|
    next if file == '.' or file == '..'
    data = Uberblog::BlogData.new("./data/#{file}")
    post = Uberblog::BlogPost.new(data.title, data.html, data.date, $siteUrl)
    html = rhtml.result(post.getBinding)
    generated = File.open("./htdocs/#{post.filename}", 'w') { |file| file.write(html) }
    list.append(post)
end

#create the index
template = File.open("./templates/index.rhtml", "rb") { |file| file.read }
rhtml    = ERB.new(template)
index    = rhtml.result(list.getBinding)
File.open("./htdocs/index.html", 'w') { |file| file.write(index) }

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
File.open("./htdocs/feed.xml","w") { |file| file.write(feed) }

#create the google site map
template = File.open("./templates/sitemap.erb", "rb") { |file| file.read }
rhtml    = ERB.new(template)
sitemap  = Uberblog::SiteMap.new($siteUrl)
Find.find("./htdocs") do |file|
    if file =~ /.html$/
        sitemap.append(file)
    end
end
xml = rhtml.result(sitemap.getBinding)
File.open("./htdocs/sitemap.xml","w") { |f| f.write(xml) }