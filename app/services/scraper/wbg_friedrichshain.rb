# frozen_string_literal: true

module Scraper
  class WbgFriedrichshain
    BASE_URL = "https://www.wbg-friedrichshain-eg.de"
    LIST_URL = "#{BASE_URL}/wohnungsangebote".freeze

    def get_requests()
      self.request = Typhoeus::Request.new(LIST_URL)
    end

    def call
      raise StandardError.new request.response.return_code unless request.response.success?
      page = Nokogiri::HTML(request.response.body)
      page
        .css(".jea_item")
        .reject { |listing| listing.text.include?("Gewerbefläche") }
        .map { |listing| parse(listing) }
    end

    private

    attr_accessor :request

    def parse(listing)
      Apartment.new(
        external_id: "wbg-friedrichshain-#{url(listing)}",
        properties: {
          address: listing.css("p").first.text.strip.gsub(/[[:space:]]+/, " "),
          url: url(listing),
          rooms_number: rooms_number(listing)
        }
      )
    end

    def url(listing)
      "#{BASE_URL}#{listing.at('a').attribute('href').value}"
    end

    def rooms_number(listing)
      Integer(listing.text.match(/Zimmer:[[:blank:]](\d*)/)[1])
    end
  end
end
