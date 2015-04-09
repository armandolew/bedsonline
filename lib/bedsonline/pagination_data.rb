require 'nokogiri'

module Bedsonline
  class PaginationData
    attr_accessor :current_page, :total_pages, :per_page
    def self.from_xml(xml_string)
      doc = Nokogiri::XML(xml_string)
      pagination_data = PaginationData.new
      pagination_data.current_page = doc.at_css('PaginationData')['currentPage']
      pagination_data.total_pages = doc.at_css('PaginationData')['totalPages']
      pagination_data
    end
  end
end
