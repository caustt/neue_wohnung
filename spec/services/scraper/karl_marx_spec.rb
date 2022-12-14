# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_request"

RSpec.describe Scraper::KarlMarx do
  before(:each) do
    mock_request = MockRequest.new("karlmarx.html")
    allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
    service = Scraper::KarlMarx.new()
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
      .to eq "Newtonstraße 25, 14480 Potsdam"
  end

  it "assigns external identifier" do
    expect(@result.first.external_id).to eq "karlmarx-https://www.wgkarlmarx.de/fuer-wohnungssucher/expose/wohnen-am-stern-2-raum-wohnung-zu-vermieten"
  end

  it "gets link to the full offer" do
    expect(@result.first.properties.fetch("url"))
      .to eq "https://www.wgkarlmarx.de/fuer-wohnungssucher/expose/wohnen-am-stern-2-raum-wohnung-zu-vermieten"
  end

  it "gets the number of rooms" do
    expect(@result.first.properties.fetch("rooms_number"))
      .to eq 2
  end

  it "gets the warm rent" do
    expect(@result.first.properties.fetch("warm_rent").to_d)
      .to eq 450.59.to_d
  end
end
