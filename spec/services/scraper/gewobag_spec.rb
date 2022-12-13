# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_request"

RSpec.describe Scraper::Gewobag do
  before(:each) do
    mock_request = MockRequest.new("gewobag.html")
    allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
    service = Scraper::Gewobag.new()
    service.get_requests
    @result = service.call
  end

  it "gets multiple apartments" do
    expect(@result.size).to eq 8
  end

  it "returns Apartment instances" do
    expect(@result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    expect(@result.first.properties.fetch("address"))
      .to eq "Richard-Münch-Str. 42, 13591 Berlin/Staaken"
  end

  it "assigns external identifier" do
    expect(@result.first.external_id).to eq "gewobag-43925"
  end

  it "gets link to the full offer" do
    expect(@result.first.properties.fetch("url"))
      .to eq "https://www.gewobag.de/fuer-mieter-und-mietinteressenten/mietangebote/7100-74806-0305-0076/"
  end

  it "gets the number of rooms" do
    expect(@result.first.properties.fetch("rooms_number"))
      .to eq 3
  end

  it "gets the WBS status" do
    expect(@result.first.properties.fetch("wbs"))
      .to eq false
  end
end
