require 'nokogiri'
require 'bedsonline/utils'
require 'bedsonline/hotel_room'
require 'bedsonline/hotel_room_guest'
require 'bedsonline/models/hotel_description'

module Bedsonline
  class HotelService
    attr_accessor :date_from, :date_to, :currency, :hotel_name, :avail_token,
      :hotel_info_code, :images, :category, :destination_code, :destination_type,
      :latitude, :longitude, :available_rooms, :child_age_from, :child_age_to,
      :contract_name, :incoming_office_code

    def self.from_xml(xml_string)
      hotels = []
      doc = Nokogiri::XML(xml_string)
      doc.css('ServiceHotel').each do |hotel_service_node|
        hotel_service = Nokogiri::XML(hotel_service_node.to_s)
        hotel = HotelService.new
        hotel.date_from             = hotel_service.at_css('DateFrom')['date']
        hotel.date_to               = hotel_service.at_css('DateTo')['date']
        hotel.currency              = hotel_service.at_css('Currency')['code']
        hotel.hotel_name            = hotel_service.at_css('HotelInfo Name').content
        hotel.avail_token           = hotel_service.at_css('ServiceHotel')['availToken']
        hotel.hotel_info_code       = hotel_service.at_css('HotelInfo Code').content
        hotel.images                = hotel_service.css('HotelInfo ImageList Image Url').map {|node| node.content}
        hotel.category              = hotel_service.at_css('Category')['shortname']
        hotel.destination_code      = hotel_service.at_css('Destination')['code']
        hotel.destination_type      = hotel_service.at_css('Destination')['type']
        hotel.latitude              = hotel_service.at_css('Position')['latitude']
        hotel.longitude             = hotel_service.at_css('Position')['longitude']
        hotel.child_age_from        = hotel_service.at_css('ChildAge')['ageFrom']
        hotel.child_age_to          = hotel_service.at_css('ChildAge')['ageTo']
        hotel.available_rooms       = HotelRoom.from_node_list(hotel_service.css('AvailableRoom'))
        hotel.contract_name         = hotel_service.at_css('ContractList Contract Name').content
        hotel.incoming_office_code  = hotel_service.at_css('ContractList Contract IncomingOffice')['code']
        hotels << hotel
        #$stdout.puts(hotel.inspect)
      end
      hotels
    end

    def minimum_price
      rooms = self.available_rooms.map { |available_room| available_room.room_price.to_f }
      rooms.sort!
      rooms.first
    end

    def description
      hotel_description = Bedsonline::Models::HotelDescription.find_by_LanguageCode_and_HotelCode('CAS', hotel_info_code.to_i)
      hotel_description.nil? ? nil : hotel_description.HotelFacilities.force_encoding('UTF-8').encode('UTF-8')
    end
  end
end
