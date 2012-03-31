require 'uberblog/model'

module Uberblog

  module UnitTests

    module Model

      class ModuleTest < Test::Unit::TestCase

        must 'create date' do
          assert_equal Time.utc('2010', '03', '23'), Uberblog::Model.create_date('2010-03-23_1')
          assert_nil Uberblog::Model.create_date('foobar')
          assert_nil Uberblog::Model.create_date('foobar_1')
          assert_nil Uberblog::Model.create_date('2010-3_1')
          assert_nil Uberblog::Model.create_date('2010-33-45_0')
        end

        must 'generate slug url' do
          #assert_equal 'this-is-a-title', Uberblog::Model.generate_slug_url('This is A TITLE')
          assert_equal 'this-with-12-34-number-and-signgs', Uberblog::Model.generate_slug_url('-This with 12.34 number! and - signgs?')
        end

      end

      class MarkdownDataTest < Test::Unit::TestCase

        def load_kramdown_document(file)
          File.open(file, "rb") { |f| Kramdown::Document.new(f.read) }
        end

        must 'extract meta data' do
          document = load_kramdown_document("#{$FIXTURES}/blog_post.md")
          meta     = {}
          assert_equal meta, Uberblog::Model::MarkdownData.extract_meta_data(document)

          document = load_kramdown_document("#{$FIXTURES}/blog_post_with_meta.md")
          meta     = {'Title' => 'Some title', 'Foo' => 'Bar'}
          assert_equal meta, Uberblog::Model::MarkdownData.extract_meta_data(document)
        end

        must 'parse meta data' do
          meta = {}
          assert_equal meta, Uberblog::Model::MarkdownData.parse_meta_data('')

          meta = {}
          assert_equal meta, Uberblog::Model::MarkdownData.parse_meta_data('foobar')
          assert_equal meta, Uberblog::Model::MarkdownData.parse_meta_data('foo bar baz')

          meta = {'Title' => 'Some title', 'Foo' => 'Bar'}
          assert_equal meta, Uberblog::Model::MarkdownData.parse_meta_data("Title: Some title\nFoo: Bar")
        end

        must 'is key?' do
          assert_equal true, Uberblog::Model::MarkdownData.is_key?('Key:')
          assert_equal true, Uberblog::Model::MarkdownData.is_key?('key:')
          assert_equal false, Uberblog::Model::MarkdownData.is_key?('Key')
          assert_equal false, Uberblog::Model::MarkdownData.is_key?('key')
        end

      end

      class RatingTest < Test::Unit::TestCase

        must 'count and calc average' do
          rating = Uberblog::Model::Rating.new
          assert_equal 0, rating.sum
          assert_equal 0, rating.average
          assert_equal 0, rating.count

          rating.add(5)
          assert_equal 5, rating.sum
          assert_equal 5, rating.average
          assert_equal 1, rating.count

          rating.add(3)
          assert_equal 8, rating.sum
          assert_equal 4, rating.average
          assert_equal 2, rating.count
        end

      end

    end

  end

end
