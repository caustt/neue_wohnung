# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_request"

RSpec.describe Scraper::Degewo do
  before(:each) do
    mock_request = MockRequest.new("degewo.json")
    mock_response = mock_request.response
    allow(Typhoeus).to receive(:get).and_return(mock_response)
    service = Scraper::Degewo.new()
    @result = service.call
  end

  it "gets multiple apartments" do
    expect(@result.size).to eq 10
  end

  it "returns Apartment instances" do
    expect(@result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    expect(@result.first.properties.fetch("address"))
      .to eq "Alfred-Döblin-Straße 12 | 12679 Berlin"
  end

  it "gets link to the full offer" do
    expect(@result.first.properties.fetch("url"))
      .to eq "https://immosuche.degewo.de/de/properties/W1400-40137-0620-0603"
  end

  it "assigns external identifier" do
    expect(@result.first.external_id).to eq "degewo-https://immosuche.degewo.de/de/properties/W1400-40137-0620-0603"
  end

  it "gets the number of rooms" do
    expect(@result.first.properties.fetch("rooms_number"))
      .to eq 1
  end

  it "gets the WBS status" do
    expect(@result.first.properties.fetch("wbs"))
      .to eq false
  end

  context 'empty page' do 
    it "gets all apartments when pagination is present" do
      sites = ["degewo_page_1.json", "degewo_page_2.json", "degewo_page_3.json"]
      mock_responses =  sites.map { |site| MockRequest.new(site).response }
      allow(Typhoeus).to receive(:get).and_return(*mock_responses)
      service = Scraper::Degewo.new()
      result = service.call

      expect(result.size).to eq 25
    end
  end
end
