
module Uberblog

  module View

    class BlogPostList

      def initialize()
        @posts  = Array.new
      end

      def add(aBlogPost)
        unless @posts.empty?
          @posts[0].nextPost = aBlogPost.url
          aBlogPost.prevPost = @posts[0].url
        end

        @posts.unshift(aBlogPost)
      end

      def posts
        @posts
      end

      def each(&blk)
        @posts.each(&blk)
      end

    end

  end

end