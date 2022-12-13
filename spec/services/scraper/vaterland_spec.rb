# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_request"

RSpec.describe Scraper::Vaterland do
  before(:each) do
    mock_request = MockRequest.new("vaterland.html")
    allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
    service = Scraper::Vaterland.new()
    service.get_requests
    @result = service.call
  end

  it "gets multiple apartments" do
    expect(@result.size).to eq 3
  end

  it "returns Apartment instances" do
    expect(@result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    expect(@result.first.properties.fetch("address"))
      .to eq "Manteuffelstraße 2, 12103 Berlin"
  end

  it "returns link to the list page as there are no individual pages" do
    expect(@result.first.properties.fetch("url"))
      .to eq "https://www.bg-vaterland.de/index.php?id=31"
  end

  it "assigns external identifier" do
    expect(@result.first.external_id).to eq(
      "vaterland-Manteuffelstraße 2 | 12103 Berlin | 2-Zimmer-Wohnung | ca. 58,04 qm | 4. OG rechts"
    )
  end

  it "gets the number of rooms" do
    expect(@result.first.properties.fetch("rooms_number"))
      .to eq 2
  end

  context "with half rooms" do
    it "correctly parses the number of rooms for half rooms" do
      mock_request = MockRequest.new("vaterland_half_room.html")
      allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
      service = Scraper::Vaterland.new()
      service.get_requests
      result = service.call

      expect(result.first.properties.fetch("rooms_number"))
        .to eq 1
    end
  end
end
