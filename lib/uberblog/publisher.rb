
module Uberblog

  class Publisher
    attr_writer :purge, :sites, :quiet, :drafts, :source, :target
    attr_accessor :logger, :verbose

    def initialize
      @verbose = false
    end

    def publish
      generate_sites(@source + '/sites', @target + '/sites') if @sites
      generate_posts(@source + '/posts', @target + '/posts')
      generate_drafts(@source + '/drafts', @target + '/drafts') if @drafts
      generate_index(@target)
      generate_site_map(@target)
      generate_rss(@target)
    end

    private
    def be_verbose(message)
      @logger.log(message) if @verbose and !logger.nil?
    end

    def generate_sites(source, target)
      be_verbose "Generate sites..."
    end

    def generate_posts(source, target)
      be_verbose "Generate posts..."
      title, url = "Title", "http://..."
      post_to_twitter(title, url)
    end

    def generate_drafts(source, target)
      be_verbose "Generate drafts..."
      generate_sites(source + '/sites', target + '/sites')
      generate_posts(source + '/posts', target + '/posts')
    end

    def post_to_twitter(title, url)
      be_verbose "Post to twitter..."
    end

    def generate_index(target)
      be_verbose "Generate index..."
    end

    def generate_site_map(target)
       be_verbose "Generate site map..."
    end

    def generate_rss(target)
      be_verbose "Generate RSS..."
    end
  end

end