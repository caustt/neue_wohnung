# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_request"

RSpec.describe Scraper::Vbveg do
  before(:each) do
    mock_request = MockRequest.new("vbveg.html")
    allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
    service = Scraper::Vbveg.new()
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
      .to eq "Hussitenstr. 7, 13355 Berlin"
  end

  it "returns link to the list page as there are no individual pages" do
    expect(@result.first.properties.fetch("url"))
      .to eq "https://www.vbveg.de/wohnungsangebote.html"
  end

  it "assigns external identifier" do
    expect(@result.first.external_id).to eq(
      "vbveg-Hussitenstr. 7, 13355 Berlin-484.81"
    )
  end

  it "gets the number of rooms" do
    expect(@result.first.properties.fetch("rooms_number"))
      .to eq 1
  end

  it "gets the WBS status when WBS is required" do
    expect(@result.first.properties.fetch("wbs"))
      .to eq true
  end

  it "gets the warm rent" do
    expect(@result.first.properties.fetch("warm_rent"))
      .to eq "484.81"
  end

  context "with empty page" do
    it "returns zero apartments" do
      mock_request = MockRequest.new("vbveg_empty.html")
      allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
      service = Scraper::Vbveg.new()
      service.get_requests
      result = service.call

      expect(result.size).to eq 0
    end
  end
end
