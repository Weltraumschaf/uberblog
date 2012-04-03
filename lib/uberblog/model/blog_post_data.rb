require 'uberblog/model/markdown_data'

module Uberblog

  module Model

    class BlogPostData < MarkdownData

      def BlogPostData.create_date(filename)
        return nil if filename.index('_').nil?

        dateParts = filename[0, filename.index('_')].split(/-/)

        return nil if 3 != dateParts.size
        return nil if dateParts.any? { |part| part.nil? or part.to_i == 0}

        begin
          return Time.utc(dateParts[0], dateParts[1], dateParts[2])
        rescue
          return nil
        end
      end

      def date
        BlogPostData.create_date(@basename)
      end

      def <=>(other)
        date <=> other.date
      end

      def to_s
        "<BlogData: #{title}, #{date}>"
      end

    end

  end

end
