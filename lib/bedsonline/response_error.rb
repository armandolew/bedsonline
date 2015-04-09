require 'nokogiri'

module Bedsonline
  class ResponseError
    attr_accessor :code, :timestamp, :message, :detailed_message

    def self.from_node_list(node_list)
      errors = []
      node_list.each do |error_node|
        error_service = Nokogiri::XML(error_node.to_s)
        error = ResponseError.new
        error.code             = error_service.at_css('Code').content
        error.timestamp        = error_service.at_css('Timestamp').content
        error.message          = error_service.at_css('Message').content
        error.detailed_message = error_service.at_css('DetailedMessage').content
        errors << error
      end
      errors
    end
  end
end