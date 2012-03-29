
module Uberblog

  class Publisher
    attr_writer :purge, :sites, :quiet, :drafts, :source, :target

    def publish
      generate_sites(@source + '/sites', @target + '/sites') if @sites
      generate_posts(@source + '/posts', @target + '/posts')
      generate_drafts(@source + '/drafts', @target + '/drafts') if @drafts
      generate_index(@target)
      generate_site_map(@target)
      generate_rss(@target)
    end

    def generate_sites(source, target)

    end

    def generate_posts(source, target)
      post_to_twitter(title, url)
    end

    def generate_drafts(source, target)
      generate_sites(source + '/sites', target + '/sites')
      generate_posts(source + '/posts', target + '/posts')
    end

    def post_to_twitter(title, url)

    end

    def generate_index(target)

    end

    def generate_site_map(target)

    end

    def generate_rss(target)

    end
  end

end