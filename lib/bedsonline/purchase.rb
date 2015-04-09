require 'nokogiri'
require 'bedsonline/service'
require 'bedsonline/reference'
require 'bedsonline/hotel_room_guest'
require 'bedsonline/invoice_company'

module Bedsonline
  class Purchase
    attr_accessor :token, :time_to_expiration, :status, :agency_code, :agency_branch, :services, :currency,
                  :payment_type_code, :payment_description, :total_price, :pending_amount, :file_number,
                  :incoming_office_code, :creation_date, :holder, :agency_reference, :reference, :invoice_company

    def self.from_xml(xml_string)
      doc = Nokogiri::XML(xml_string)
      purchase_service = Nokogiri::XML(doc.at_css('Purchase').to_s)
      purchase = Purchase.new
      purchase.token                = purchase_service.at_css('Purchase')['purchaseToken']
      purchase.time_to_expiration   = purchase_service.at_css('Purchase')['timeToExpiration']
      purchase.status               = purchase_service.at_css('Status').content
      purchase.agency_code          = purchase_service.at_css('Agency Code').content
      purchase.agency_branch        = purchase_service.at_css('Agency Branch').content
      purchase.services             = Service.from_node_list(purchase_service.css('ServiceList'))
      purchase.currency             = purchase_service.at_css('Currency')['code']
      purchase.payment_type_code    = purchase_service.at_css('PaymentData PaymentType')['code']
      purchase.payment_description  = purchase_service.at_css('Description').content
      purchase.total_price          = purchase_service.at_css('TotalPrice').content
      purchase.pending_amount       = purchase_service.at_css('PendingAmount').content
      # Additional fields to support purchase confirmation.
      if purchase_service.at_css('Reference')
        reference_attributes = {}
        reference_attributes[:file_number]     = purchase_service.at_css('Reference FileNumber').content
        reference_attributes[:incoming_office] = purchase_service.at_css('Reference IncomingOffice')['code']
        purchase.reference                     = Reference.new(reference_attributes)
      end
      purchase.creation_date = purchase_service.at_css('CreationDate')['date'] if purchase_service.at_css('CreationDate')
      if purchase_service.at_css('Holder')
        holder_attributes = {}
        holder_attributes[:type]       = purchase_service.at_css('Holder')['type']
        holder_attributes[:age]        = purchase_service.at_css('Holder Age').content
        holder_attributes[:first_name] = purchase_service.at_css('Holder Name').content
        holder_attributes[:last_name]  = purchase_service.at_css('Holder LastName').content
        purchase.holder                = HotelRoomGuest.new(holder_attributes)
      end
      purchase.agency_reference = purchase_service.at_css('AgencyReference').content if purchase_service.at_css('AgencyReference')
      if purchase_service.at_css('InvoiceCompany')
        invoice_company_attributes = {}
        invoice_company_attributes[:code]                = purchase_service.at_css('InvoiceCompany Code').content                if purchase_service.at_css('InvoiceCompany Code')
        invoice_company_attributes[:name]                = purchase_service.at_css('InvoiceCompany Name').content                if purchase_service.at_css('InvoiceCompany Name')
        invoice_company_attributes[:registration_number] = purchase_service.at_css('InvoiceCompany RegistrationNumber').content  if purchase_service.at_css('InvoiceCompany RegistrationNumber')
        purchase.invoice_company                         = InvoiceCompany.new(invoice_company_attributes)
      end
      purchase
    end
  end
end
