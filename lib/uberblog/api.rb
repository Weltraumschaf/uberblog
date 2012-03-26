require 'uberblog/db'
require 'uberblog/model'

module Uberblog

  module Api

    class Service

      def initialize(dbFile)
        @ratingRepository = Uberblog::Db::RatingsTable.new(dbFile).create_repository
      end

      def get_all_ratings
        [
          'all-web-developers-should-stop-doing-this-immediately-too',
          'darcs-in-hudson-jenkins-ci',
          'debian-and-the-outdated-ruby-gems',
          'failure-modes-in-scrum',
          'fuck-of-wordpress',
          'good-thinking-good-products',
          'hudson-vs-jenkins',
          'keynes-vs-hayek',
          'launched-website-for-a-video-cutter',
          'maven-and-arbitrary-jar-files',
          'nice-objective-c-2-0-tutorial',
          'nice-resources-for-learning-ruby',
          'ninjaui-jquery``-ui-library',
          'only-ssl-access-to-my-blog',
          'parser-and-image-generator-for-ebnf',
          'plugins-to-harden-your-wordpress',
          'post-to-twitter-with-ruby',
          'recomened-books-for-learning-objective-c-and-cocoa',
          'unit-test-your-cocoa-application-with-ghunit',
          'what-causes-e-strict-errors-in-php',
          'writing-compilers-and-interpreters-a-software-engineering-approach'
        ]
      end

      def get_rating(post)
        #@ratingRepository.find_by_post(post)
        Uberblog::Model::Rating.new('post-id', 18, 5)
      end

      def set_rating(post, rate)
        rating = get_rating(post)
        rating = Uberblog::Model::Rating.new(post) if rating.nil?
        rating.add rate
        @ratingRepository.save rating
      end

    end
  end
end