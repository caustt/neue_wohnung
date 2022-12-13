# frozen_string_literal: true

module Scraper
  class WbgHub
    URL = "https://www.wbg-hub.de/wohnen/wohnungsangebote"

    def get_requests()
      self.request = Typhoeus::Request.new(URL, :followlocation => true)
    end

    def call
      raise StandardError.new request.response.return_code unless request.response.success?
      page = Nokogiri::HTML(request.response.body)
      page.css(".immo-flexbox").map { |listing| parse(listing) }
    end

    private

    attr_accessor :request

    def parse(listing)
      Apartment.new(
        external_id: "wbg-hub-#{url(listing)}",
        properties: {
          address: listing.css(".card-text").text.strip.split(/\s+/).join(" "),
          url: url(listing),
          rooms_number: Integer(listing.css(".text-center").text.match(/(\d)+\s+Zimmer/)[1])
        }
      )
    end

    def url(listing)
      "#{URL}/#{listing.at('a.stretched-link').attribute('href').value}"
    end
  end
end
