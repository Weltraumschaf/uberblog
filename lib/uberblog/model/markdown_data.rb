require 'kramdown'

module Uberblog

  module Model

    class MarkdownData

      attr_reader :metadata, :basename

      def MarkdownData.is_key?(str)
        58 == str[str.size - 1] # Last character is :?
      end

      def MarkdownData.parse_meta_data(text)
        hash    = {}
        lastKey = nil

        text.split.each do |splitter|
          if MarkdownData.is_key?(splitter)
            lastKey = splitter[0, splitter.size - 1]
            hash[lastKey] = ''
          else
            break if lastKey.nil?

            hash[lastKey] += ' ' if hash[lastKey].size > 0
            hash[lastKey] += splitter
          end
        end

        hash
      end

      def MarkdownData.extract_meta_data(document)
        firstElement = document.root.children[0]
        return {} if firstElement.nil? or firstElement.type != :p
        return self.parse_meta_data(firstElement.children[0].value)
      end

      def MarkdownData.remove_meta_data(document)
        copy = document.dup
        copy.root.children.delete_at(0)
        copy
      end

      def initialize(filename)
        @basename = Pathname.new(filename).basename.to_s
        @document = File.open(filename, "rb") { |file| Kramdown::Document.new(file.read) }
        @metadata = MarkdownData.extract_meta_data(@document)
      end

      def to_html
        return @document.to_html if self.metadata.size == 0 # No metadata to remove.
        return MarkdownData.remove_meta_data(@document).to_html
      end

      def title
        return @title unless @title.nil?

        @title = ''
        @document.root.children.each do |child|
          @title = child.children[0].value if :header == child.type and 2 == child.options()[:level]
        end

        @title
      end
    end

  end

end
