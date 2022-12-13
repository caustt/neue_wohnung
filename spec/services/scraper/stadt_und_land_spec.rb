# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_request"

RSpec.describe Scraper::StadtUndLand do
  before(:each) do
    mock_request = MockRequest.new("stadt_und_land.html")
    allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
    service = Scraper::StadtUndLand.new()
    service.get_requests
    @result = service.call
  end

  it "gets multiple apartments" do
    expect(@result.size).to eq 5
  end

  it "returns Apartment instances" do
    expect(@result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    expect(@result.first.properties.fetch("address"))
      .to eq "Potsdamer Str. 80, 14974 Ludwigsfelde"
  end

  it "gets link to the full offer" do
    expect(@result.first.properties.fetch("url"))
      .to eq "https://www.stadtundland.de/exposes/immo.MO_I998_5199_103.php"
  end

  it "assigns external identifier" do
    expect(@result.first.external_id).to eq "stadt-und-land-https://www.stadtundland.de/exposes/immo.MO_I998_5199_103.php"
  end

  it "gets the number of rooms" do
    expect(@result.first.properties.fetch("rooms_number"))
      .to eq 2
  end

  it "gets the WBS status when the listing is without WBS" do
    expect(@result.first.properties.fetch("wbs"))
      .to eq false
  end

  it "gets the WBS status when the listing is with WBS" do
    expect(@result.second.properties.fetch("wbs"))
      .to eq true
  end

  context "garage listing" do
    it "ignores listing for garage" do
      mock_request = MockRequest.new("stadt_und_land_garage.html")
      allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
      service = Scraper::StadtUndLand.new()
      service.get_requests
      result = service.call

      expect(result.size).to eq 9
    end
  end

  context "parking place listing" do
    it "ignores listing for parking place" do
      mock_request = MockRequest.new("stadt_und_land_parking_place.html")
      allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
      service = Scraper::StadtUndLand.new()
      service.get_requests
      result = service.call

      expect(result.size).to eq 6
    end
  end
end
