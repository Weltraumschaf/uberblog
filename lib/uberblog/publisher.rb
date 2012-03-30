#require 'twitter'
#require 'bitly'
require 'erb'
require 'uberblog/blog'
require 'uberblog/sitemap'
require 'uberblog/model'

module Uberblog

  class Publisher
    attr_writer :purge, :sites, :quiet, :drafts, :source, :target
    attr_accessor :logger, :verbose

    def initialize(config)
      @config  = config
      @verbose = false
      @layout  = Uberblog::Layout.new(@config.siteUrl, create_template("layout"), @config.language)
      @layout.headline    = @config.headline
      @layout.description = @config.description
      @layout.apiUrl      = @config.api['url']
    end

    def publish
      puts 'Publishing the blog...'
      #generate_sites(@source + '/sites', @target + '/sites') if @sites
      posts = generate_posts(@source + '/posts', @target + '/posts')
      generate_index(@target, posts)
      #generate_drafts(@source + '/drafts', @target + '/drafts') if @drafts
      #generate_site_map(@target)
      #generate_rss(@target)
    end

    private
    def be_verbose(message)
      @logger.log(message) if @verbose and !logger.nil?
    end

    def to_long?(msg)
      msg.length > 140
    end

    def create_template(name)
      File.open("#{@config.tplDir}/#{name}.erb", "rb") { |file| ERB.new(file.read) }
    end

    def load_files(dirname)
      fileList = []

      Dir.foreach(dirname) do |file|
        next if file == '.' or file == '..'
        fileList << "#{dirname}/#{file}"
      end

      fileList
    end

    def load_posts(source)
      dataList = []

      load_files(source).each do |file|
        be_verbose "Loading file '#{file}'."
        dataList << Uberblog::BlogData.new(file)
      end

      list = Uberblog::BlogPostList.new()
      dataList.sort.each do |data|
        post = Uberblog::BlogPost.new(data, @config)
        list.add(post)
      end

      list
    end

    def generate_sites(source, target)
      be_verbose "Generate sites..."
    end

    def generate_posts(source, target)
      be_verbose "Generate posts..."
      count    = 0
      template = create_template("post")
      list     = load_posts(source)
      list.each do |post|
        @layout.title   = "#{@config.headline} | #{post.title}"
        @layout.content = template.result(post.get_binding)
        targetFile      = "#{target}/#{post.filename}"

        if File.exist?(targetFile) && !@purge
          be_verbose("Skip regeneration of '#{Pathname.new(targetFile).realpath.to_s}'.")
          next
        end

        update_twitter(post.title, post.url) unless File.exist?(targetFile) or @quiet

        File.open(targetFile, 'w') do |file|
          be_verbose("Write post to '#{Pathname.new(targetFile).realpath.to_s}'.")
          file.write(@layout.to_html)
        end

        count +=1
      end

      puts "#{count} posts generated."
      list
    end

    def generate_drafts(source, target)
      be_verbose "Generate drafts..."
      generate_sites(source + '/sites', target + '/sites')
      generate_posts(source + '/posts', target + '/posts')
    end

    def update_twitter(title, url)
      be_verbose "Post to twitter..."

      @logger.error "Not implemented yet!"
      return
      begin
        Bitly.use_api_version_3
        bitly = Bitly.new(@config['bitly']['username'], @config['bitly']['apikey'])
        url = bitly.shorten(longUrl).short_url
      rescue BitlyError
        url = longUrl
      end

      #url.sub!('http:', '').sub!('https:', '')
      msg = "#{title} - #{url}"

      if to_long? msg
        reduce = msg.length - 140 + 3
        title = title[0, reduce] + '...'
      end

      msg = "#{title} - #{url}"

      if to_long? msg
        msg = "Blogged: #{url}"
      end

      if to_long? msg
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

    def generate_index(target, posts)
      be_verbose "Generate index..."
      layout = Uberblog::Model::Layout.new(create_template('layout'), @config.siteUrl);
      layout.title       = "#{@config.headline} | Blog"
      layout.headline    = @config.headline
      layout.description = @config.description
      layout.apiUrl      = @config.api['url']
      index  = Uberblog::Model::Index.new(create_template('index'), layout)
      index.posts = posts
      File.open("#{target}/index.html", 'w') { |file| file.write(index.to_html) }
    end

    def generate_site_map(target)
       be_verbose "Generate site map..."

       site_map = Uberblog::SiteMap.new(@config['siteUrl'], create_template("site_map"))

       Find.find(@htdocs) do |file|
         if file =~ /.html$/
           site_map.append(file)
         end
       end

       File.open("#{@htdocs}/sitemap.xml", "w") { |f| f.write(site_map.to_xml) }
    end

    def generate_rss(target)
      be_verbose "Generate RSS..."

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
  end

end