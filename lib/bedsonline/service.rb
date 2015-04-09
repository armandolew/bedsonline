require 'nokogiri'
require 'bedsonline/additional_cost'
require 'bedsonline/destination_zone'
require 'bedsonline/reference'
require 'bedsonline/contract'
require 'bedsonline/comment'

module Bedsonline
  class Service
    attr_accessor :spui, :status, :direct_payment, :supplier_name, :supplier_vat_number, :date_from, :date_to,
                  :currency, :total_amount, :additional_costs, :modification_policies, :hotel_code, :hotel_name,
                  :hotel_category_type, :hotel_category_code, :destination_type, :destination_code, :destination_name,
                  :destination_zones, :rooms, :contracts, :reference, :comments, :additional_cost_pvp_equivalent

    def initialize
      @modification_policies = []
    end

    def self.from_node_list(node_list)
      services = []
      node_list.each do |service_node|
        node = Nokogiri::XML(service_node.to_s)
        service = Service.new
        service.spui                     = node.at_css('Service')['SPUI']
        service.status                   = node.at_css('Status').content
        service.direct_payment           = node.at_css('DirectPayment').content
        service.contracts                = Contract.from_node_list(node.at_css('ContractList Contract'))
        service.supplier_name            = node.at_css('Supplier')['name']
        service.supplier_vat_number      = node.at_css('Supplier')['vatNumber']
        service.date_from                = node.at_css('DateFrom')['date']
        service.date_to                  = node.at_css('DateTo')['date']
        service.currency                 = node.at_css('Currency')['code']
        service.total_amount             = node.at_css('TotalAmount').content
        service.additional_costs         = AdditionalCost.from_node_list(node.css('AdditionalCostList AdditionalCost'))
        service.additional_costs.each {|cost| cost.currency = node.at_css('AdditionalCostList Currency')['code']}
        node.css('ModificationPolicyList ModificationPolicy').each do |modification_policy|
          service.modification_policies << modification_policy.content
        end
        service.hotel_code               = node.at_css('HotelInfo Code').content
        service.hotel_name               = node.at_css('HotelInfo Name').content
        service.hotel_category_type      = node.at_css('HotelInfo Category')['type']
        service.hotel_category_code      = node.at_css('HotelInfo Category')['code']
        service.destination_type         = node.at_css('HotelInfo Destination')['type']
        service.destination_code         = node.at_css('HotelInfo Destination')['code']
        service.destination_name         = node.at_css('HotelInfo Destination Name').content
        service.destination_zones        = DestinationZone.from_node_list(node.css('HotelInfo Destination ZoneList'))
        service.rooms                    = HotelRoom.from_node_list(node.css('AvailableRoom'))
        # Additional fields to support purchase confirmation.
        if node.at_css('Reference')
          reference_attributes = {}
          reference_attributes[:file_number]     = node.at_css('Reference FileNumber').content
          reference_attributes[:incoming_office] = node.at_css('Reference IncomingOffice')['code']
          service.reference                      = Reference.new(reference_attributes)
        end
        service.comments                       = Comment.from_node_list(node.css('CommentList Comment')) if node.css('CommentList')
        service.additional_cost_pvp_equivalent = node.at_css('AdditionalCostList PvpEquivalent').content if node.at_css('AdditionalCostList PvpEquivalent')
        services << service
      end
      services
    end

    def holder
      self.rooms.first.guests.first
    end
  end
end
