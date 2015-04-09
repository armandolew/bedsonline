require 'spec_helper'
require 'active_support/all'

describe Bedsonline::Client do
  before :each do
    @client = Bedsonline::Client.new(ENV['BEDSONLINE_USER'], ENV['BEDSONLINE_PASSWORD'], ENV['BEDSONLINE_PROXY'])
    @check_in = 7.day.from_now
    @check_out = 10.days.from_now
  end

  describe "initialization" do
    it "should initialize with an credentials and proxy params" do
      client = Bedsonline::Client.new('user', 'pass', 'http://exampleproxy.com')
      expect(client).to_not eql nil
      expect(client.uses_proxy?).to be_truthy
    end

    it "should initialize with an credentials and no proxy params" do
      client = Bedsonline::Client.new('user', 'pass')
      expect(client).to_not eql nil
      expect(client.uses_proxy?).to be_falsey
    end

    it "should use proxy if specified in param" do
      expect(@client.uses_proxy?).to be_truthy
    end
  end

  describe "request generation" do
    it "should render hotel valued avail request from template" do
      rendered = @client.render_hotel_valued_avail('MIA', @check_in, @check_out, { order: {}})
      expect(rendered).to_not eql nil
      expect(rendered).to_not be_empty
    end
  end

  describe "utils" do
    it "should delete utf8 strings" do
      string = "hello\255"
      result = Bedsonline::Utils.clean_utf8(string)
      expect(result).to eql 'hello'
    end
  end
end
