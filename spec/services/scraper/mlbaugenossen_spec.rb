# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_request"

RSpec.describe Scraper::Mlbaugenossen do
  before(:each) do
    mock_request = MockRequest.new("mlbaugenossen.html")
    allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
    service = Scraper::Mlbaugenossen.new()
    service.get_requests
    @result = service.call
  end

  it "gets available apartments" do
    expect(@result.size).to eq 1
  end

  it "returns Apartment instances" do
    expect(@result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    expect(@result.first.properties.fetch("address"))
      .to eq "Rathausstraße 93 Gartenhaus, 12105 Berlin"
  end

  it "links to the page with all offers" do
    expect(@result.first.properties.fetch("url"))
      .to eq "https://www.mlbaugenossen.de/angebote-mietobjekte/aktuelle-wohnangebote.html"
  end

  it "assigns external identifier" do
    expect(@result.first.external_id).to eq "mlbaugenossen-2/12/131"
  end

  it "gets the number of rooms" do
    expect(@result.first.properties.fetch("rooms_number"))
      .to eq 1
  end
end
