# frozen_string_literal: true

module Scraper
  class Mlbaugenossen
    URL = "https://www.mlbaugenossen.de/angebote-mietobjekte/aktuelle-wohnangebote.html"

    def get_requests()
      self.request = Typhoeus::Request.new(URL)
    end

    def call
      raise StandardError.new request.response.return_code unless request.response.success?
      page = Nokogiri::HTML(request.response.body)
      page.css(".angebotdetails").map { |listing| parse(listing) }
    end

    private

    attr_accessor :request

    def parse(listing)
      Apartment.new(
        external_id: "mlbaugenossen-#{listing.css('.td')[0].text}",
        properties: {
          address: listing.css(".td")[1].text,
          url: URL,
          rooms_number: Integer(listing.css(".td")[2].text)
        }
      )
    end
  end
end
