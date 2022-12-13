# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_request"

RSpec.describe Scraper::Bbg do
  context 'empty page' do 
    it "returns 0 apartments for empty page" do
      mock_request = MockRequest.new("bbg_empty.html")
      allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
      service = Scraper::Bbg.new()
      service.get_requests
      result = service.call
      
      expect(result.size).to eq 0
    end
  end

  context 'number of rooms not available' do 
    it "returns apartment even when the number of rooms is not available" do
      mock_request = MockRequest.new("bbg_no_rooms.html")
      allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
      service = Scraper::Bbg.new()
      service.get_requests
      result = service.call
  
      expect(result.first.properties.key?("rooms_number")).to eq false
    end
  end

  before(:each) do
    mock_request = MockRequest.new("bbg.html")
    allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
    service = Scraper::Bbg.new()
    service.get_requests
    @result = service.call
  end

  it "gets multiple apartments when they are available" do
    expect(@result.size).to eq 2
  end

  it "returns Apartment instances" do
    expect(@result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    expect(@result.first.properties.fetch("address"))
      .to eq "Mariendorfer Damm 8 12109 Berlin"
  end

  it "assigns external identifier" do
    expect(@result.first.external_id).to eq "bbg-117/116/181"
  end

  it "gets link to the full offer" do
    expect(@result.first.properties.fetch("url"))
      .to eq "https://bbg-eg.de/angebote/wohnungen-und-gewerbe/"
  end

  it "gets the number of rooms" do
    expect(@result.first.properties.fetch("rooms_number"))
      .to eq 2
  end
end
