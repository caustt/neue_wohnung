# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_request"

RSpec.describe Scraper::WbgHub do
  before(:each) do
    mock_request = MockRequest.new("wbg_hub.html")
    allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
    service = Scraper::WbgHub.new()
    service.get_requests
    @result = service.call
  end

  it "gets multiple apartments" do
    expect(@result.size).to eq 2
  end

  it "returns Apartment instances" do
    expect(@result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    expect(@result.first.properties.fetch("address"))
      .to eq "Pablo-Picasso-Str. 1 13057 Berlin"
  end

  it "gets link to the full offer" do
    expect(@result.first.properties.fetch("url"))
      .to eq "https://www.wbg-hub.de/wohnen/wohnungsangebote/28-1-37-moderne-1-zimmer-wohnung-in-berlin-hohenschnhausen/"
  end

  it "assigns external identifier" do
    expect(@result.first.external_id).to eq "wbg-hub-https://www.wbg-hub.de/wohnen/wohnungsangebote/28-1-37-moderne-1-zimmer-wohnung-in-berlin-hohenschnhausen/"
  end

  it "gets the number of rooms" do
    expect(@result.first.properties.fetch("rooms_number"))
      .to eq 1
  end
end
