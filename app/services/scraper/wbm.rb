# frozen_string_literal: true

module Scraper
  class Wbm
    BASE_URL = "https://www.wbm.de"
    LIST_URL = "#{BASE_URL}/wohnungen-berlin/angebote/".freeze

    def get_requests()
      self.request = Typhoeus::Request.new(LIST_URL)
    end

    def call
      raise StandardError.new request.response.return_code unless request.response.success?
      page = Nokogiri::HTML(request.response.body)
      page.css(".openimmo-search-list-item").map { |listing| parse(listing) }
    end

    private

    attr_accessor :request

    def parse(listing)
      Apartment.new(
        external_id: "wbm-#{listing.attribute('data-id').value}",
        properties: {
          address: listing.css(".address").text.split(",").join(", "),
          url: url(listing),
          rooms_number: rooms_number(listing),
          wbs: listing.css(".check-property-list").text.include?("WBS")
        }
      )
    end

    def url(listing)
      value = listing.css(".btn.sign").attribute("href").value

      if value.start_with?("https")
        value
      else
        "#{BASE_URL}#{value}"
      end
    end

    def rooms_number(listing)
      Integer(listing.css(".main-property-list").text.match(/Zimmer:(\d*)/)[1])
    end
  end
end
