# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_request"

RSpec.describe Scraper::WbgFriedrichshain do
  before(:each) do
    mock_request = MockRequest.new("wbg_friedrichshain.html")
    allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
    service = Scraper::WbgFriedrichshain.new()
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
      .to eq "Zechliner Str. 2A, 2B 13055 Berlin, Hohenschönhausen"
  end

  it "assigns external identifier" do
    expect(@result.first.external_id).to eq "wbg-friedrichshain-https://www.wbg-friedrichshain-eg.de/wohnungsangebote/343-moderne-2-zimmer-wohnung-mit-grosser-kueche"
  end

  it "gets link to the full offer" do
    expect(@result.first.properties.fetch("url"))
      .to eq "https://www.wbg-friedrichshain-eg.de/wohnungsangebote/343-moderne-2-zimmer-wohnung-mit-grosser-kueche"
  end

  it "gets the number of rooms" do
    expect(@result.first.properties.fetch("rooms_number"))
      .to eq 2
  end

  it "skips the listing if it is a business space" do
    mock_request = MockRequest.new("wbg_friedrichshain_business.html")
    allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
    service = Scraper::WbgFriedrichshain.new()
    service.get_requests
    result = service.call

    expect(result.size).to eq 0
  end
end
