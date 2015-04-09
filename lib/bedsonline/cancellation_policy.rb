require 'nokogiri'

module Bedsonline
  class CancellationPolicy
    attr_accessor :amount, :date_from, :time

    def self.from_node_list(node_list)
      policies = []
      node_list.each do |policy_node|
        policy_service = Nokogiri::XML(policy_node.to_s)
        policy = CancellationPolicy.new
        policy.amount    = policy_service.at_css('CancellationPolicy')['amount']
        policy.date_from = policy_service.at_css('CancellationPolicy')['dateFrom']
        policy.time      = policy_service.at_css('CancellationPolicy')['time']
        policies << policy
      end
      policies
    end
  end
end