require 'uberblog/view/html'

module Uberblog

  module View

    class Site < Html
      attr_accessor :title, :content, :data, :baseUrl

      def title
        @data.title
      end

      def content
        @data.to_html
      end

      def filename
        @data.basename.gsub(".md", ".html")
      end

      def url
        @baseUrl + filename
      end

      def navi
        @data.metadata['Navi']
      end

    end

  end

end
