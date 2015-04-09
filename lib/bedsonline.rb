require 'bedsonline/version'
require 'bedsonline/hotel_service'
require 'bedsonline/purchase'
require 'bedsonline/pagination_data'
require 'bedsonline/response_error'
require 'ostruct'
require 'httparty'
require 'uri'
require 'nokogiri'

module Bedsonline
  class Client
    include HTTParty
    base_uri 'https://testapi.interface-xml.com/'

    BEDSONLINE_DATE_FORMAT = "%Y%m%d"
    BEDSONLINE_DEFAULT_OPTIONS = { room_count: 1, adult_count: 1, child_count: 0,
      items_per_page: 4, page_number: 1, order: { name: 'ORDER_CONTRACT_PRICE', value: 'ASC'} }
    BEDSONLINE_AVAIL_TOKEN = 'RUBYAVAILTOKEN12345'


    ORDER_BY_PRICE_DESC = { name: 'ORDER_CONTRACT_PRICE', value: 'DESC'}
    ORDER_BY_PRICE_ASC = { name: 'ORDER_CONTRACT_PRICE', value: 'ASC'}

    attr_accessor :user, :pass, :proxy, :proxy_addr, :proxy_port, :proxy_user, :proxy_pass, :per_page
    attr_reader :errors

    def initialize(user, pass, http_proxy = nil)
      @errors = []
      @user = user
      @pass = pass
      @proxy = http_proxy
      if http_proxy.nil?
        @uses_proxy = false
      else
        @uses_proxy = true
        uri = URI.parse(@proxy)
        @proxy_addr = uri.host
        @proxy_port = uri.port
        @proxy_user = uri.user
        @proxy_pass = uri.password
        self.class.http_proxy @proxy_addr, @proxy_port, @proxy_user, @proxy_pass
      end
      self.per_page = 4
      BEDSONLINE_DEFAULT_OPTIONS[:items_per_page] = self.per_page
    end

    def uses_proxy?
      @uses_proxy
    end

    def operations
      [:search_hotels, :add_service, :confirm_purchase]
    end

    def search_hotels(destination, check_in, check_out, options = {})
      actual_options = BEDSONLINE_DEFAULT_OPTIONS.merge(options)
      body = render_hotel_valued_avail(destination,
        check_in.strftime(BEDSONLINE_DATE_FORMAT), check_out.strftime(BEDSONLINE_DATE_FORMAT),
        actual_options)
      response = post_to_service(body)
      errors = response_errors(response.body)
      unless errors
        hotel_services = find_hotel_services_in_xml(response.body)
      else
        @errors << errors
        hotel_services = { hotels: [] }
      end
      hotel_services
    end

    def add_service(hotel_service, hotel_room)
      body = render_service_add_request(hotel_service, hotel_room)
      response = post_to_service(body)
      errors = response_errors(response.body)
      unless errors
        purchase = Purchase.from_xml(response.body)
      else
        @errors << errors
      end
      purchase
    end

    def confirm_purchase(purchase, service)
      body = render_purchase_confirm_request(purchase, service)
      response = post_to_service(body)
      errors = response_errors(response.body)
      unless errors
        response_body = response.body
      else
        @errors << errors
      end
      response_body
    end

    def find_hotel_services_in_xml(xml_string)
      $stdout.puts xml_string
      hotels = HotelService.from_xml(xml_string)
      pagination_data = PaginationData.from_xml(xml_string)
      pagination_data.per_page = self.per_page
      { hotels: hotels, pagination_data: pagination_data}
    end

    def post_to_service(body)
      self.class.post('/appservices/http/FrontendService', body: body, headers: { 'Content-Type' => 'application/xml' })
    end

    def render_hotel_valued_avail(destination, check_in_date, check_out_date, options)
      namespace = OpenStruct.new(username: @user, password: @pass,
        destination: destination, check_in_date: check_in_date, check_out_date: check_out_date,
        room_count: options[:room_count], adult_count: options[:adult_count], child_count: options[:child_count],
        items_per_page: options[:items_per_page], page_number: options[:page_number], order: options[:order] )
      erb_path = File.expand_path('../templates/hotel_valued_avail.xml.erb', __FILE__)
      template = ERB.new(File.read(erb_path))
      template.result(namespace.instance_eval {binding} )
    end

    def render_service_add_request(hotel_service, hotel_room)
      namespace = OpenStruct.new(username: @user, password: @pass,
                                avail_token: hotel_service.avail_token,
                                contract_name: hotel_service.contract_name,
                                incoming_office_code: hotel_service.incoming_office_code,
                                date_from: hotel_service.date_from,
                                date_to: hotel_service.date_to,
                                code: hotel_service.hotel_info_code,
                                destination_code: hotel_service.destination_code,
                                destination_type: hotel_service.destination_type,
                                available_room: hotel_room.available_room_xml)
      erb_path = File.expand_path('../templates/hotel_service_add.xml.erb', __FILE__)
      template = ERB.new(File.read(erb_path))
      template.result(namespace.instance_eval { binding })
    end

    def render_purchase_confirm_request(purchase, service)
      namespace = OpenStruct.new(username: @user, password: @pass,
        purchase: purchase, service: service)
      erb_path = File.expand_path('../templates/purchase_confirm.xml.erb', __FILE__)
      template = ERB.new(File.read(erb_path))
      template.result(namespace.instance_eval { binding })
    end

    def render_purchase_cancel_request(purchase, service, options = {})
      type = {:type => 'V'}.merge(options)[:type]
      namespace = OpenStruct.new(username: @user, password: @pass,
        purchase: purchase, service: service, type: type)
      erb_path = File.expand_path('../templates/purchase_cancel.xml.erb', __FILE__)
      template = ERB.new(File.read(erb_path))
      template.result(namespace.instance_eval { binding })
    end

    def response_errors(xml_string)
      doc = Nokogiri::XML(xml_string)
      error_list = Nokogiri::XML(doc.at_css('ErrorList').to_s)
      errors = ResponseError.from_node_list(error_list.css('Error'))
      errors.size > 0 ? errors : nil
    end
  end
end
