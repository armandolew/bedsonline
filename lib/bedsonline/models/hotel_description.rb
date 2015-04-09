require 'active_record'

module Bedsonline
  module Models
    class HotelDescription < ActiveRecord::Base
      establish_connection ENV['BEDSONLINE_DATABASE_URL']
      self.table_name = 'HOTEL_DESCRIPTIONS'
    end
  end
end
