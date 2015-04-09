module Bedsonline
  class InvoiceCompany
    attr_accessor :code, :name, :registration_number

    def initialize(attributes = {})
      @code                = attributes[:code]
      @name                = attributes[:name]
      @registration_number = attributes[:registration_number]
    end
  end
end