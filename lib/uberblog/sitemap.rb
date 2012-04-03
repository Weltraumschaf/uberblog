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

    def append(url)
      @urls << url
    end

    def to_xml
      @template.result(binding)
    end
  end
end
