require 'uberblog/view/html'

module Uberblog

  module View

    # Mobe into module view or presentation
    class Index < Html
      attr_accessor :posts

      def initialize(template, layout)
        super(template, layout)
        @posts = []
      end

    end

  end

end
