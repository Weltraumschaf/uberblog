require 'uberblog/model/markdown_data'

module Uberblog

  module Model

    class SiteData < MarkdownData

      def to_s
        "<SiteData: #{title}>"
      end

    end

  end

end
