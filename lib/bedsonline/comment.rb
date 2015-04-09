require 'nokogiri'

module Bedsonline
  class Comment
    attr_accessor :type, :content

    def self.from_node_list(node_list)
      comments = []
      node_list.each do |comment_node|
        comment_service = Nokogiri::XML(comment_node.to_s)
        comment = Comment.new
        comment.type    = comment_service.at_css('Comment')['type']
        comment.content = comment_service.at_css('Comment').content
        comments << comment
      end
      comments
    end
  end
end