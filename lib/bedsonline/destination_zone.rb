require 'nokogiri'

module Bedsonline
  class DestinationZone
    attr_accessor :type, :code, :description

    def self.from_node_list(node_list)
      zones = []
      node_list.each do |zone_node|
        zone_service = Nokogiri::XML(zone_node.to_s)
        zone = DestinationZone.new
        zone.type        = zone_service.at_css('Zone')['type']
        zone.code        = zone_service.at_css('Zone')['code']
        zone.description = zone_service.at_css('Zone').content
        zones << zone
      end
      zones
    end
  end
end