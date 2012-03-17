require 'uberblog'
require 'erb'

# crate the blog posts
template = File.open("./templates/post.rhtml", "rb") { |file| file.read }
rhtml = ERB.new(template)
posts = Uberblog::BlogPostList.new

Dir.foreach("./data") do |file|
    next if file == '.' or file == '..'
    data = Uberblog::BlogData.new("./data/#{file}")
    post = Uberblog::BlogPost.new(data.title, data.html, data.date)
    generated = File.new("./htdocs/#{post.filename}", 'w')
    generated.write(rhtml.result(post.getBinding))
    generated.close
    posts.append(post)
end

#create the index
template = File.open("./templates/index.rhtml", "rb") { |file| file.read }
rhtml = ERB.new(template)
generated = File.new("./htdocs/index.html", 'w')
generated.write(rhtml.result(posts.getBinding))
#create the feeds

#create the google site map