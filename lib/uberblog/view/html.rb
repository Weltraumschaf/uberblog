
module Uberblog

  module View

    # Mobe into module view or presentation
    class Html
      attr_accessor :profileLinks, :otherLinks
      attr_reader :template, :layout

      def initialize(template, layout)
        @template = template
        @layout   = layout
      end

      def to_html
        @layout.content = @template.result binding
        @layout.to_html
      end
    end

  end

end