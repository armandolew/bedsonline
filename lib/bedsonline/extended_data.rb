require 'nokogiri'

module Bedsonline
  class ExtendedData
    attr_accessor :name, :value

    def self.from_node_list(node_list)
      extended_data_list = []
      node_list.each do |extended_data_node|
        extended_data_service = Nokogiri::XML(extended_data_node.to_s)
        extended_data = ExtendedData.new
        extended_data.name  = extended_data_service.at_css('Name').content
        extended_data.value = extended_data_service.at_css('Value').content
        extended_data_list << extended_data
      end
      extended_data_list
    end
  end
end