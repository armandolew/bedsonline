require 'nokogiri'

module Bedsonline
  class AdditionalCost
    attr_accessor :currency, :type, :amount

    def self.from_node_list(node_list)
      additional_costs = []
      node_list.each do |cost_node|
        additional_cost_service = Nokogiri::XML(cost_node.to_s)
        additional_cost = AdditionalCost.new
        additional_cost.type   = additional_cost_service.at_css('AdditionalCost')['type']
        additional_cost.amount = additional_cost_service.at_css('AdditionalCost Price Amount').content
        additional_costs << additional_cost
      end
      additional_costs
    end
  end
end