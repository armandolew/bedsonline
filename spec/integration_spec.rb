require 'spec_helper'
require 'active_support/all'


describe "Bedsonline Shopping Process" do
  before :each do
    @client = Bedsonline::Client.new(ENV['BEDSONLINE_USER'], ENV['BEDSONLINE_PASSWORD'], ENV['BEDSONLINE_PROXY'])
    @check_in = 20.day.from_now
    @check_out = 24.days.from_now
  end

  it "should call service add after looking for hotel availability" do
    result = @client.search_hotels('MIA', @check_in, @check_out)
    hotel_service = result[:hotels].first
    room = hotel_service.available_rooms.first
    room.guests = [ Bedsonline::HotelRoomGuest.new({age: 30, type: 'AD', first_name: 'Ricardo', last_name: 'Echavarria'}) ]
    purchase = @client.add_service(hotel_service, room)
    purchase ? $stdout.puts(purchase.inspect) : $stdout.puts(@client.errors.last.inspect)
    expect(purchase).to_not eql nil
    service = purchase.services.first
    purchase_response = @client.confirm_purchase(purchase, service)
    $stdout.puts(purchase_response)
    $stdout.puts(@client.errors.last.inspect)
  end

  it "should call the service add request" do
    room = Bedsonline::HotelRoom.new
    room.room_count = 1
    room.adult_count = 1
    room.child_count = 0
    room.guests = [Bedsonline::HotelRoomGuest.new({age: 35, type: 'AD', first_name: 'Juan', last_name: 'Perez'})]
    room.board_code = "RO-MX1"
    room.board_type ="SIMPLE"
    room.room_characterisctics = "EC"
    room.room_code = "DBL-MX1"
    room.room_type ="SIMPLE"
    service = Bedsonline::HotelService.new
    service.avail_token = '184fvjMdoAHvwiVTMPxiiA2k'
    service.contract_name = 'PVP-TODOS'
    service.incoming_office_code = "69"
    service.date_from = '20140923'
    service.date_to = '20140926'
    service.hotel_info_code = '237551'
    service.destination_code = 'CUN'
    service.destination_type = 'SIMPLE'
    @client.add_service(service, room)
    expect(@client.errors.size).to be > 0
  end
end
