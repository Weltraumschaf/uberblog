require 'uberblog/view/html'

module Uberblog

  module View

    # Mobe into module view or presentation
    class BlogPost < Html

      attr_reader :features
      attr_accessor :prevPost, :nextPost, :config, :data, :baseUrl, :features

      def BlogPost.generate_slug_url(path)
        slug = path.downcase.gsub(/[^a-z0-9]/, '-').gsub(/-+/, '-')

        if 45 == slug[0]
          slug = slug[1, slug.size - 1]
        end

        if 45 == slug[slug.size - 1]
          slug = slug[0, slug.size - 1]
        end

        slug
      end

      def title
        @data.title
      end

      def content
        @data.to_html
      end

      def date
        @data.date
      end

      def <=> other
        self.date <=> other.date
      end

      def filename
        "#{BlogPost.generate_slug_url(self.title)}.html"
      end

      def date_formatted
        self.date.strftime('%d.%m.%Y')
      end

      def url
        @baseUrl + filename
      end

      def to_s
        "<BlogPost: #{filename}, #{@date}>"
      end

    end

  end

end
