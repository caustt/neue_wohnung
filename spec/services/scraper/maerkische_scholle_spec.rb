# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_request"

RSpec.describe Scraper::MaerkischeScholle do
  before(:each) do
    mock_request = MockRequest.new("maerkische_scholle.html")
    allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
    service = Scraper::MaerkischeScholle.new()
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
      .to eq "Holtheimer Weg 30 (Lichterfelde-Süd)"
  end

  it "assigns external identifier" do
    expect(@result.first.external_id)
      .to eq "maerkische-scholle-files/bilder/content/wohungsangebote/2020/A3a_Holth.30_2_Zi_2.OGre.png"
  end

  it "links to the page with all offers" do
    expect(@result.first.properties.fetch("url"))
      .to eq "https://www.maerkische-scholle.de/wohnungsangebote.html"
  end

  it "gets the number of rooms" do
    expect(@result.first.properties.fetch("rooms_number"))
      .to eq 2
  end

  it "gets the WBS status when WBS is not required" do
    expect(@result.second.properties.fetch("wbs")).to eq false
  end

  context "with WBS required" do
    it "gets the WBS status when WBS is required" do
      mock_request = MockRequest.new("maerkische_scholle_wbs.html")
      allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
      service = Scraper::MaerkischeScholle.new()
      service.get_requests
      result = service.call

      expect(result.first.properties.fetch("wbs")).to eq true
    end
  end
end
