# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_request"

RSpec.describe Scraper::Dpf do
  before(:each) do
    mock_request = MockRequest.new("dpf.html")
    allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
    service = Scraper::Dpf.new()
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
      .to eq "Mittelstraße 2, 13158 Berlin"
  end

  it "assigns external identifier" do
    expect(@result.first.external_id).to eq "dpf-https://www.dpfonline.de/immobilien/wohnkomfort-in-rosenthal-2-grosszuegige-zimmer-mit-wohlfuehl-terasse/"
  end

  it "gets link to the full offer" do
    expect(@result.first.properties.fetch("url"))
      .to eq "https://www.dpfonline.de/immobilien/wohnkomfort-in-rosenthal-2-grosszuegige-zimmer-mit-wohlfuehl-terasse/"
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


  context 'number of rooms not available' do 
      it "rounds down the number of rooms when there are half rooms" do
      mock_request = MockRequest.new("dpf_half_room.html")
      allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
      service = Scraper::Dpf.new()
      service.get_requests
      result = service.call

      expect(result.fourth.properties.fetch("rooms_number"))
        .to eq 2
    end
  
  end
end
