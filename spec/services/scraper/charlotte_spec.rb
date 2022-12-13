# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_request"

RSpec.describe Scraper::Charlotte do
  before(:each) do
    mock_request = MockRequest.new("charlotte.html")
    allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
    service = Scraper::Charlotte.new()
    service.get_requests
    @result = service.call
  end

  it "gets multiple apartments" do
    expect(@result.size).to eq 10
  end

  it "returns Apartment instances" do
    expect(@result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    expect(@result.first.properties.fetch("address"))
      .to eq "Hohenzollernring 98-98d | 13585 Berlin"
  end

  it "assigns external identifier" do
    expect(@result.first.external_id).to eq "charlotte-040-0030"
  end

  it "links to the list of all offers" do
    expect(@result.first.properties.fetch("url"))
      .to eq "https://charlotte1907.de/wohnungsangebote/woechentliche-angebote"
  end

  it "gets the number of rooms" do
    expect(@result.first.properties.fetch("rooms_number"))
      .to eq 2
  end

  it "gets the number of rooms when there are half rooms" do
    expect(@result.third.properties.fetch("rooms_number"))
      .to eq 2
  end

  it "filters out offers only for members" do
    expect(@result.map(&:external_id)).not_to include("charlotte-210-0109")
  end

  it "gets the WBS status when WBS is not required" do
    expect(@result.first.properties.fetch("wbs")).to eq false
  end

  it "gets the WBS status when WBS is required" do
    expect(@result[5].properties.fetch("wbs")).to eq true
  end

  it "gets the warm rent when warm rent is provided" do
    expect(@result.first.properties.fetch("warm_rent")).to eq "444.81"
  end

  it "gets the cold rent when cold rent is provided" do
    expect(@result[6].properties.fetch("cold_rent")).to eq "515.06"
  end

  it "gets the size of the apartment" do
    expect(@result.first.properties.fetch("size")).to eq 52
    expect(@result.second.properties.fetch("size")).to eq 59
  end
end
