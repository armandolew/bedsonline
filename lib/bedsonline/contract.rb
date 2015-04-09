require 'nokogiri'
require 'bedsonline/comment'

module Bedsonline
  class Contract
    attr_accessor :name, :incoming_office_code, :comments

    def self.from_node_list(node_list)
      contracts = []
      node_list.each do |contract_node|
        contract_service = Nokogiri::XML(contract_node.to_s)
        contract = Contract.new
        contract.name                 = contract_service.at_css('Name').content
        contract.incoming_office_code = contract_service.at_css('IncomingOffice')['code']
        contract.comments             = Comment.from_node_list(contract_service.css('CommentList Comment')) if contract_service.css('CommentList')
        contracts << contract
      end
      contracts
    end
  end
end