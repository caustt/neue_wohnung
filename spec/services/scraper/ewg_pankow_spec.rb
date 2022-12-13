# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_request"

RSpec.describe Scraper::EwgPankow do
  context 'number of rooms only in title' do
    it "gets the number of rooms when they are only in title" do
      mock_request = MockRequest.new("ewg_pankow_rooms_in_title.html")
      allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
      service = Scraper::EwgPankow.new()
      service.get_requests
      result = service.call

      expect(result.first.properties.fetch("rooms_number"))
        .to eq 2
    end
  end

  context 'empty page' do
    it "returns 0 apartments for empty page" do
      mock_request = MockRequest.new("ewg_pankow_empty.html")
      allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
      service = Scraper::EwgPankow.new()
      service.get_requests
      result = service.call

      expect(result.size).to eq 0
    end
  end

  before(:each) do
    mock_request = MockRequest.new("ewg_pankow.html")
    allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
    service = Scraper::EwgPankow.new()
    service.get_requests
    @result = service.call
  end

  it "gets apartments when they are present" do
    expect(@result.size).to eq 1
  end

  it "returns Apartment instances" do
    expect(@result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    expect(@result.first.properties.fetch("address"))
      .to eq "Groscurthstraße, Buch"
  end

  it "assigns external identifier" do
    expect(@result.first.external_id).to eq "ewg-pankow-7989"
  end

  it "gets link to the full offer" do
    expect(@result.first.properties.fetch("url"))
      .to eq "https://www.ewg-pankow.de/wohnungen/3-zimmer-groscurthstrasse-buch/"
  end

  it "gets the number of rooms" do
    expect(@result.first.properties.fetch("rooms_number"))
      .to eq 3
  end
end
