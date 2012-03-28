require 'uberblog/exec'

module Uberblog
  class Publisher < Generic

    def execute
      super
      puts 'Publishing the blog...'
      @dataDir     = Pathname.new(@baseDir + @config['dataDir']).realpath
      @htdocs      = Pathname.new(@baseDir + @config['htdocs']).realpath
      @tplDir      = Pathname.new(@baseDir + @config['tplDir']).realpath
      @list        = Uberblog::BlogPostList.new()
      @layout      = Uberblog::Layout.new(@config['siteUrl'], create_template("layout"), @config['language'])
      @layout.headline    = @config['headline']
      @layout.description = @config['description']
      @layout.apiUrl      = @config['api']['url']
      load_posts
      create_posts
      create_index
      create_feed
      create_site_map
      exit 0
    end

    protected
    def set_opts(opts)
      super
      opts.banner = 'Usage: publish -c <file> [-p] [-h]'

      opts.on('-p', '--purge', 'Regenerate all blog posts.') do
        @options[:purge] = true
      end

      opts.on('-q', '--quiet', 'Be quiet and dont post to social networks.') do
        @options[:quiet] = true
      end

    end

    private
    def create_template(name)
      File.open("#{@tplDir}/#{name}.erb", "rb") { |file| ERB.new(file.read) }
    end

    def load_posts
      dataList = []
      dirname  = "#{@dataDir}/posts"

      Dir.foreach(dirname) do |file|
        next if file == '.' or file == '..'

        dataList << Uberblog::BlogData.new("#{dirname}/#{file}")
      end

      dataList.sort.each do |data|
        post = Uberblog::BlogPost.new(data, @config)
        @list.add(post)
      end
    end

    def create_posts
      be_verbose 'Create posts...'
      count = 0
      template = create_template("post")
      @list.each do |post|
        @layout.title   = "#{@config['headline']} | #{post.title}"
        @layout.content = template.result(post.get_binding)
        targetFile      = "#{@htdocs}/#{post.filename}"

        if File.exist?(targetFile) && !@options[:purge]
          be_verbose("Skip regeneration of '#{Pathname.new(targetFile).realpath.to_s}'.")
          next
        end

        update_twitter(post.title, post.url) unless File.exist?(targetFile) or @options[:quiet]

        File.open(targetFile, 'w') do |file|
          be_verbose("Write post to '#{Pathname.new(targetFile).realpath.to_s}'.")
          file.write(@layout.to_html)
        end

        count +=1
      end

      puts "#{count} posts generated."
    end

    def create_index
      be_verbose 'Create index...'

      @layout.title   = "#{@config['headline']} | Blog"
      @layout.content = create_template("index").result(@list.get_binding)

      File.open("#{@htdocs}/index.html", 'w') { |file| file.write(@layout.to_html) }
    end

    def create_feed
      be_verbose 'Create feed...'

      feed = RSS::Maker.make('2.0') do |maker|
        maker.channel.title         = @config['headline']
        maker.channel.link          = "#{@config['siteUrl']}feed.xml"
        maker.channel.description   = @config['description']
        maker.channel.language      = @config['language']
        maker.channel.lastBuildDate = Time.now
        maker.items.do_sort         = true

        @list.posts.each do |post|
          item             = maker.items.new_item
          item.title       = post.title
          item.link        = post.url
          item.description = post.content
          item.date        = Time.parse(post.date_formatted)
        end
      end

      File.open("#{@htdocs}/feed.xml", "w") { |file| file.write(feed) }
    end

    def create_site_map
      be_verbose 'Create site map...'
      site_map = Uberblog::SiteMap.new(@config['siteUrl'], create_template("site_map"))

      Find.find(@htdocs) do |file|
        if file =~ /.html$/
          site_map.append(file)
        end
      end

      File.open("#{@htdocs}/sitemap.xml", "w") { |f| f.write(site_map.to_xml) }
    end

    def to_log?(msg)
      msg.length > 140
    end

    def update_twitter(title, longUrl)
      be_verbose("Post to twitter: #{title}...")

      begin
        Bitly.use_api_version_3
        bitly = Bitly.new(@config['bitly']['username'], @config['bitly']['apikey'])
        url = bitly.shorten(longUrl).short_url
      rescue BitlyError
        url = longUrl
      end

      #url.sub!('http:', '').sub!('https:', '')
      msg = "#{title} - #{url}"

      if to_log? msg
        reduce = msg.length - 140 + 3
        title = title[0, reduce] + '...'
      end

      msg = "#{title} - #{url}"

      if to_log? msg
        msg = "Blogged: #{url}"
      end

      if to_log? msg
        puts "Can't post to twitter! Way too manny characters."
        return
      end

      begin
        twitter = Twitter.new({
                                :consumer_key       => @config['twitter']['consumer_key'],
                                :consumer_secret    => @config['twitter']['consumer_secret'],
                                :oauth_token        => @config['twitter']['oauth_token'],
                                :oauth_token_secret => @config['twitter']['oauth_token_secret']
                              })
        twitter.update(msg)
      rescue
        puts "Error on updating twitter!"
      end
    end

  end

end