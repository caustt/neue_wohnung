# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_request"

RSpec.describe Scraper::Howoge do
  before(:each) do
    mock_request = MockRequest.new("howoge.json")
    allow(Typhoeus::Request).to receive(:new).and_return(mock_request)
    service = Scraper::Howoge.new()
    service.get_requests
    @result = service.call
  end

  it "gets multiple apartments" do
    expect(@result.size).to eq 13
  end

  it "returns Apartment instances" do
    expect(@result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    expect(@result.first.properties.fetch("address"))
      .to eq "Genslerstraße 16, 13055 Berlin"
  end

  it "gets link to the full offer" do
    expect(@result.first.properties.fetch("url"))
      .to eq "https://www.howoge.de/wohnungen-gewerbe/wohnungssuche/detail/5998.html"
  end

  it "assigns external identifier" do
    expect(@result.first.external_id).to eq "howoge-Genslerstraße 16, 13055 Berlin-788.48"
  end

  it "gets the number of rooms" do
    expect(@result.first.properties.fetch("rooms_number"))
      .to eq 2
  end

  it "gets only the offers without WBS required" do
    expect(@result.first.properties.fetch("wbs"))
      .to eq false
  end
end
