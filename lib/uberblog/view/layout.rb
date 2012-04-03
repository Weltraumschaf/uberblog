require 'uberblog/view/html'

module Uberblog

  module View

    class Layout

      attr_reader :siteUrl, :language, :template
      attr_accessor :title, :headline, :description, :content, :apiUrl, :sites, :version, :metadata

      def initialize(template, siteUrl, language = 'en')
        @template, @siteUrl, @language = template, siteUrl, language
        @title       = 'n/a'
        @headline    = 'n/a'
        @description = 'n/a'
        @content     = 'n/a'
        @apiUrl      = ''
        @profileLinks = []
        @otherLinks   = []
        @sites        = []
        @metadata     = {}
      end

      def to_html
        @template.result binding
      end
    end

  end

end
