require 'spec_helper'
require 'active_support/all'

describe "Hotel Service Add" do
  describe "Xml generation of hotel room" do
    it "should generate an xml string for the hotel service add request" do
      room = Bedsonline::HotelRoom.new
      room.room_count = 1
      room.adult_count = 1
      room.child_count = 0
      room.guests = [Bedsonline::HotelRoomGuest.new({age: 35, type: 'AD', first_name: 'Customer 1', last_name: 'Customer 1'})]
      room.board_code = "BR1"
      room.board_type ="FULL"
      room.room_characterisctics = "CHAR"
      room.room_code = "ROOM"
      room.room_type ="TYPE"
      correct_xml = "<AvailableRoom>\n  <HotelOccupancy>\n    <RoomCount>1</RoomCount>\n    <Occupancy>\n      <AdultCount>1</AdultCount>\n      <ChildCount>0</ChildCount>\n      <GuestList>\n        <Customer type=\"AD\">\n          <Age>35</Age>\n          <Name>Customer 1</Name>\n          <LastName>Customer 1</LastName>\n        </Customer>\n      </GuestList>\n    </Occupancy>\n  </HotelOccupancy>\n  <HotelRoom>\n    <Board code=\"BR1\" type=\"FULL\"/>\n    <RoomType characteristic=\"CHAR\" code=\"ROOM\" type=\"TYPE\"/>\n  </HotelRoom>\n</AvailableRoom>"
      actual_xml = room.available_room_xml
      expect(actual_xml).to eql correct_xml
    end
  end
end
