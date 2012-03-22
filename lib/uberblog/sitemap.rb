require 'pathname'

module Uberblog
  class SiteMap
    class Url
      attr_accessor :loc, :lastmod, :changefreq, :priority

      def initialize
        @changefreq, @priority = 'weekly', '0.2'
      end
    end

    attr_reader :urls

    def initialize(siteUrl, template)
      @siteUrl, @template, @urls = siteUrl, template, Array.new
    end

    def append(aFile)
      url = Url.new
      url.lastmod = File.mtime(aFile).strftime('%Y-%m-%d')
      url.loc = @siteUrl + Pathname.new(aFile).basename.to_s
      @urls.push(url)
    end

    def to_xml
      @template.result(binding)
    end
  end
end