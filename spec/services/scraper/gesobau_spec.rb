# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_request"

RSpec.describe Scraper::Gesobau do
  before(:each) do
    mock_request = MockRequest.new("gesobau.html")
    allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
    service = Scraper::Gesobau.new()
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
      .to eq "Lion-Feuchtwanger-Straße 19B / 12619 Berlin"
  end

  it "gets link to the full offer" do
    expect(@result.first.properties.fetch("url"))
      .to eq "https://www.gesobau.de/wohnung/lion-feuchtwanger-strasse-2zi-10-03239-1057-g.html"
  end

  it "assigns external identifier" do
    expect(@result.first.external_id).to eq "gesobau-https://www.gesobau.de/wohnung/lion-feuchtwanger-strasse-2zi-10-03239-1057-g.html"
  end

  it "gets the number of rooms" do
    expect(@result.first.properties.fetch("rooms_number"))
      .to eq 2
  end

  context "with error" do
    it "handles the loading error on Gesobau side" do
      mock_request = MockRequest.new("gesobau_error.html")
      allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
      service = Scraper::Gesobau.new()
      service.get_requests
      result = service.call

      expect(result.size).to eq 0
    end
  end

  context "with wbs" do
    before(:each) do 
      mock_request = MockRequest.new("gesobau_wbs.html")
      allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
      service = Scraper::Gesobau.new()
      service.get_requests
      @result = service.call
    end

    it "gets the WBS status when WBS is required" do
      expect(@result.first.properties.fetch("wbs")).to eq true
    end

    it "gets the WBS status when WBS is not required" do
      expect(@result.second.properties.fetch("wbs")).to eq false
    end
  end
end
