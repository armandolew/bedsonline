require 'nokogiri'

module Bedsonline
  class HotelRoomGuest
    attr_accessor :age, :type, :first_name, :last_name, :is_travel_agent, :id

    def initialize(attributes = {})
      self.age        = attributes[:age]
      self.type       = attributes[:type]
      self.first_name = attributes[:first_name]
      self.last_name  = attributes[:last_name]
    end

    def self.from_node_list(node_list)
      guests = []
      node_list.each do |guest_node|
        guest_service = Nokogiri::XML(guest_node.to_s)
        guest = HotelRoomGuest.new
        guest.type            = guest_service.at_css('Customer')['type']
        guest.is_travel_agent = guest_service.at_css('Customer')['isTravelAgent']
        guest.id              = guest_service.at_css('CustomerId').content
        guest.age             = guest_service.at_css('Age').content
        guest.first_name      = guest_service.at_css('Name').content
        guest.last_name       = guest_service.at_css('LastName').content
        guests << guest
      end
      guests
    end
  end
end
