# frozen_string_literal: true

module Scraper
  class NeuesBerlin
    BASE_URL = "https://www.neues-berlin.de"
    LIST_URL = "#{BASE_URL}/wohnen/wohnungsangebote".freeze

    def get_requests()
      self.request = Typhoeus::Request.new(LIST_URL)
    end

    def call
      raise StandardError.new request.response.return_code unless request.response.success?
      page = Nokogiri::HTML(request.response.body)
      page.css(".oi-sum").map { |listing| parse(listing) }
    end

    private

    attr_accessor :request

    def parse(listing)
      Apartment.new(
        external_id: "neues-berlin-#{url(listing)}",
        properties: {
          address: listing.css(".col-md-6").text.split(/\s+/).drop(2).join(" "),
          url: url(listing),
          rooms_number: Integer(listing.css(".col-md-3").first.text.match(/Zimmer\s+(\d)+/)[1])
        }
      )
    end

    def url(listing)
      "#{BASE_URL}#{listing.at('.pdf-download').attribute('href').value}"
    end
  end
end
