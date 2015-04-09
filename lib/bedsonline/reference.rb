module Bedsonline
  class Reference
    attr_accessor :file_number, :incoming_office_code

    def initialize(attributes = {})
      @file_number          = attributes[:file_number]
      @incoming_office_code = attributes[:incoming_office_code]
    end
  end
end