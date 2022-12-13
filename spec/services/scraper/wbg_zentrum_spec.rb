# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_request"

RSpec.describe Scraper::WbgZentrum do
  before(:each) do
    mock_request = MockRequest.new("wbg_zentrum.html")
    allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
    service = Scraper::WbgZentrum.new()
    service.get_requests
    @result = service.call
  end

  it "gets apartments" do
    expect(@result.size).to eq 1
  end

  it "returns Apartment instances" do
    expect(@result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    expect(@result.first.properties.fetch("address"))
      .to eq "Thälmann Park | Lilli-Henoch-Straße 9"
  end

  it "assigns external identifier" do
    expect(@result.first.external_id).to eq "wbg-zentrum-https://www.wbg-zentrum.de/wp-content/uploads/2020/12/LH-9-WE-603.pdf"
  end

  it "gets link to the full offer" do
    expect(@result.first.properties.fetch("url"))
      .to eq "https://www.wbg-zentrum.de/wp-content/uploads/2020/12/LH-9-WE-603.pdf"
  end

  it "gets the number of rooms" do
    expect(@result.first.properties.fetch("rooms_number"))
      .to eq 1
  end

  it "gets the WBS status" do
    expect(@result.first.properties.fetch("wbs"))
      .to eq true
  end
end
