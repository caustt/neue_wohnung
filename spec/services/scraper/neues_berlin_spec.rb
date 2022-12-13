# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_request"

RSpec.describe Scraper::NeuesBerlin do
  before(:each) do
    mock_request = MockRequest.new("neues_berlin.html")
    allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
    service = Scraper::NeuesBerlin.new()
    service.get_requests
    @result = service.call
  end

  it "gets multiple apartments" do
    expect(@result.size).to eq 1
  end

  it "returns Apartment instances" do
    expect(@result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    expect(@result.first.properties.fetch("address"))
      .to eq "Ahrenshooper Str. 38 13051 Berlin"
  end

  it "assigns external identifier" do
    expect(@result.first.external_id).to eq "neues-berlin-https://www.neues-berlin.de/fileadmin/angebote/cd3bf0c34d407c563a7a90f7a4f47f94.pdf"
  end

  it "gets link to the full offer" do
    expect(@result.first.properties.fetch("url"))
      .to eq "https://www.neues-berlin.de/fileadmin/angebote/cd3bf0c34d407c563a7a90f7a4f47f94.pdf"
  end

  it "gets the number of rooms" do
    expect(@result.first.properties.fetch("rooms_number"))
      .to eq 1
  end
end
