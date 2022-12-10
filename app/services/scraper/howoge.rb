# frozen_string_literal: true

module Scraper
  class Howoge
    BASE_URL = "https://www.howoge.de"
    # rubocop:disable Layout/LineLength
    LIST_URL = "#{BASE_URL}/?type=999&tx_howsite_json_list[action]=immoList&tx_howsite_json_list[wbs]=wbs-not-necessary&tx_howsite_json_list[limit]=100".freeze
    # rubocop:enable Layout/LineLength

    def get_requests()
      self.request = Typhoeus::Request.new(LIST_URL)
    end

    def call
      raise StandardError.new request.response.return_code unless request.response.success?
      json = JSON.parse(request.response.body)
      json.fetch("immoobjects").map do |listing|
        Apartment.new(
          external_id: "howoge-#{listing.fetch('title')}-#{listing.fetch('rent')}",
          properties: {
            address: listing.fetch("title"),
            url: "#{BASE_URL}#{listing.fetch('link')}",
            rooms_number: listing.fetch("rooms"),
            wbs: false
          }
        )
      end
    end

    private

    attr_accessor :request
  end
end
