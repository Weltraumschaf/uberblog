require 'erb'
require 'find'
require 'rss'
require 'twitter'
require 'bitly'
require 'pathname'
require 'uberblog/sitemap'
require 'uberblog/model/site_data'
require 'uberblog/model/blog_post_data'
require 'uberblog/view/index'
require 'uberblog/view/layout'
require 'uberblog/view/site'
require 'uberblog/view/blog_post'
require 'uberblog/view/blog_post_list'

module Uberblog

  class Publisher
    attr_writer :purge, :sites, :quiet, :drafts, :source, :target
    attr_accessor :logger, :verbose

    DIR_NAMES = {
      :sites  => 'sites',
      :posts  => 'posts',
      :drafts => 'drafts'
    }

    def initialize(config)
      @config  = config
      @verbose = false
      @drafts  = false
    end

    def publish
      puts 'Publishing the blog...'
      sites = generate_sites(@source, @target)
      posts = generate_posts(@source, @target, sites)
      generate_index(@target, posts, sites)
      generate_site_map(@target, posts, sites)
      generate_rss(@target, posts)
      generate_drafts(@source, @target, sites) if @drafts
    end

    private

    def join_file_names(*args)
      args.join('/')
    end

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

    def create_layout
      layout = Uberblog::View::Layout.new(create_template('layout'), @config.siteUrl)
      layout.title       = "n/a"
      layout.headline    = @config.headline
      layout.description = @config.description
      layout.apiUrl      = @config.api['url']
      layout.version     = Uberblog::VERSION
      layout
    end

    def create_html_resource(name, layout)
      name = name.downcase
      tpl  = create_template(name)

      case name
      when "site"
        Uberblog::View::Site.new(tpl, layout)
      when "index"
        Uberblog::View::Index.new(tpl, layout)
      when "post"
        Uberblog::View::BlogPost.new(tpl, layout)
      end

    end

    def generate_sites(s, t, allSites = [])
      be_verbose "Generate sites..."
      source = join_file_names(s, DIR_NAMES[:sites])
      target = join_file_names(t, DIR_NAMES[:sites])
      layout = create_layout
      sites  = []

      load_files(source).each do |file|
        be_verbose "Generate site for '#{file}'..."
        data         = Uberblog::Model::SiteData.new(file)
        layout.metadata = data.metadata
        site         = create_html_resource('site', layout)
        site.data    = data
        site.baseUrl = @config.siteUrl + DIR_NAMES[:sites] + '/'
        sites    << site
        allSites << site
      end

      layout.sites = allSites

      if @sites
        count = 0
        sites.each do |site|
          layout.title = "#{@config.headline} | #{site.title}"
          File.open("#{target}/#{site.filename}", 'w') { |file| file.write(site.to_html) }
          count += 1
        end
        puts "#{count} sites generated."
      end

      allSites
    end

    def generate_posts(s, t, sites)
      be_verbose "Generate posts..."

      source = join_file_names(s, DIR_NAMES[:posts])
      target = join_file_names(t, DIR_NAMES[:posts])

      count  = 0
      layout = create_layout
      layout.sites = sites
      data   = []

      # Loading data from files.
      load_files(source).each do |file|
        be_verbose "Loading file '#{file}'."
        data << Uberblog::Model::BlogPostData.new(file)
      end

      list = Uberblog::View::BlogPostList.new()
      # Sort and create posts.
      data.sort.each do |item|
        post          = create_html_resource('post', layout)
        post.data     = item
        post.features = @config.features
        post.baseUrl  = @config.siteUrl + DIR_NAMES[:posts].to_s + '/'
        list.add(post)
      end

      # First add all posts to the list to update prev/next pagination, then write them.
      list.each do |post|
        layout.title = "#{@config.headline} | #{post.title}"
        targetFile   = "#{target}/#{post.filename}"

        if File.exist?(targetFile) && !@purge
          be_verbose("Skip regeneration of '#{Pathname.new(targetFile).realpath.to_s}'.")
          next
        end

        update_twitter(post.title, post.url) unless File.exist?(targetFile) or @quiet

        File.open(targetFile, 'w') do |file|
          be_verbose("Write post to '#{Pathname.new(targetFile).realpath.to_s}'.")
          file.write(post.to_html)
        end

        count +=1
      end

      puts "#{count} posts generated."
      list
    end

    def generate_drafts(s, t, sites)
      be_verbose "Generate drafts..."

      source = join_file_names(s, DIR_NAMES[:drafts])
      target = join_file_names(t, DIR_NAMES[:drafts])

      backup = @quiet
      @quiet = true # supress twitter for drafts
      sitesWithDrafts = generate_sites(source, target, sites)
      generate_posts(source, target, sitesWithDrafts)

      @quiet = backup
    end

    def update_twitter(title, longUrl)
      be_verbose "Post to twitter..."

      begin
        Bitly.use_api_version_3
        bitly = Bitly.new(@config.bitly['username'], @config.bitly['apikey'])
        url = bitly.shorten(longUrl).short_url
      rescue BitlyError
        url = longUrl
      end

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
          :consumer_key       => @config.twitter['consumer_key'],
          :consumer_secret    => @config.twitter['consumer_secret'],
          :oauth_token        => @config.twitter['oauth_token'],
          :oauth_token_secret => @config.twitter['oauth_token_secret']
        })
        twitter.update(msg)
      rescue
        puts "Error on updating twitter!"
      end
    end

    def generate_index(target, posts, sites)
      be_verbose "Generate index..."

      layout = create_layout
      layout.sites = sites
      layout.title = "#{@config.headline} | Blog"
      index  = create_html_resource('index', layout)
      index.posts = posts
      File.open("#{target}/index.html", 'w') { |file| file.write(index.to_html) }
    end

    def generate_site_map(target, posts, sites)
      be_verbose "Generate site map..."

      site_map = Uberblog::SiteMap.new(@config.siteUrl, create_template("site_map"))

      posts.each do |post|
        #File.mtime(aFile).strftime('%Y-%m-%d')
        url = Uberblog::SiteMap::Url.new
        url.loc = post.url
        url.lastmod = Time.now.strftime('%Y-%m-%d')
        site_map.append(url)
      end

      sites.each do |site|
        url = Uberblog::SiteMap::Url.new
        url.loc = site.url
        url.lastmod = Time.now.strftime('%Y-%m-%d')
        site_map.append(url)
      end

      File.open("#{target}/sitemap.xml", "w") { |f| f.write(site_map.to_xml) }
    end

    def generate_rss(target, posts)
      be_verbose "Generate RSS..."

      feed = RSS::Maker.make('2.0') do |maker|
        maker.channel.title         = @config.headline
        maker.channel.link          = "#{@config.siteUrl}feed.xml"
        maker.channel.description   = @config.description
        maker.channel.language      = @config.language
        maker.channel.lastBuildDate = Time.now
        maker.items.do_sort         = true

        posts.posts.each do |post|
          item             = maker.items.new_item
          item.title       = post.title
          item.link        = post.url
          item.description = post.content
          item.date        = Time.parse(post.date_formatted)
        end
      end

      File.open("#{target}/feed.xml", "w") { |file| file.write(feed) }
    end
  end

end
