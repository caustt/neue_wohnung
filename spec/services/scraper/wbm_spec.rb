# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_request"

RSpec.describe Scraper::Wbm do
  before(:each) do
    mock_request = MockRequest.new("wbm.html")
    allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
    service = Scraper::Wbm.new()
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
      .to eq "Karl-Marx-Allee 4, 10178 Berlin"
  end

  it "assigns external identifier" do
    expect(@result.first.external_id).to eq "wbm-1-4361/1/8"
  end

  it "gets link to the full offer" do
    expect(@result.first.properties.fetch("url"))
      .to eq "https://www.wbm.de/wohnungen-berlin/angebote/details/1-436118-2-zimmer-wohnung-in-mitte/"
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

  it "returns the absolute URL when relative is present" do
    expect(@result.second.properties.fetch("url"))
      .to eq "https://www.wbm.de/wohnungen-berlin/angebote/details/1-436112358-2-zimmer-wohnung-in-mitte/"
  end
end
