require 'nokogiri'
require 'bedsonline/cancellation_policy'
require 'bedsonline/hotel_room_guest'
require 'bedsonline/extended_data'

module Bedsonline
  class HotelRoom
    attr_accessor :room_count, :adult_count, :child_count, :shrui, :avail_count,
      :room_code, :room_price, :room_type, :room_characterisctics, :board_code,
      :board_type, :guests, :status, :cancellation_policies, :extended_data

    def self.from_node_list(node_list)
      rooms = []
      node_list.each do |room_node|
        node = Nokogiri::XML(room_node.to_s)
        room = HotelRoom.new
        room.room_count            = node.at_css('HotelOccupancy RoomCount').content
        room.adult_count           = node.at_css('HotelOccupancy AdultCount').content
        room.child_count           = node.at_css('HotelOccupancy ChildCount').content
        room.shrui                 = node.at_css('HotelRoom')['SHRUI']
        room.avail_count           = node.at_css('HotelRoom')['availCount']
        room.room_code             = node.at_css('HotelRoom RoomType')['code']
        room.room_type             = node.at_css('HotelRoom RoomType')['type']
        room.room_characterisctics = node.at_css('HotelRoom RoomType')['characteristic']
        room.room_price            = node.at_css('HotelRoom Price Amount').content
        room.board_code            = node.at_css('HotelRoom Board')['code']
        room.board_type            = node.at_css('HotelRoom Board')['type']
        # Added for the serviceAddRS
        room.status                = node.at_css('HotelRoom')['status']
        room.guests                = HotelRoomGuest.from_node_list(node.css('HotelOccupancy Occupancy GuestList'))
        room.cancellation_policies = CancellationPolicy.from_node_list(node.css('HotelRoom CancellationPolicies'))
        # Additional fields to support purchase confirmation.
        room.extended_data         = ExtendedData.from_node_list(node.css('HotelRoomExtraInfo ExtendedData')) if node.css('HotelRoomExtraInfo')
        rooms << room
      end
      rooms
    end

    def available_room_xml
      builder = Nokogiri::XML::Builder.new do
        AvailableRoom {
          HotelOccupancy {
            RoomCount self.room_count
            Occupancy {
              AdultCount self.adult_count
              ChildCount self.child_count
              GuestList {
                self.guests.each do |guest|
                  Customer(type: guest.type){
                    Age guest.age
                    Name guest.first_name
                    LastName guest.last_name
                  }
                end
              }
            }
          }
          HotelRoom{
            Board( code: self.board_code, type: self.board_type)
            RoomType(characteristic: self.room_characterisctics, code: self.room_code, type: self.room_type)
          }
        }
      end
      builder.doc.root.to_s
    end
  end
end
