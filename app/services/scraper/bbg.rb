# frozen_string_literal: true

module Scraper
  class Bbg
    URL = "https://bbg-eg.de/angebote/wohnungen-und-gewerbe/"

    def get_requests()
      self.request = Typhoeus::Request.new(URL)
    end

    def call
      raise StandardError.new request.response.return_code unless request.response.success?
      page = Nokogiri::HTML(request.response.body)
      page.css("#std-content table.avia-table tr:not(.avia-heading-row)").map { |listing| parse(listing) }
    end

    private

    
    attr_accessor :request

    def parse(listing)
      properties = {
        address: listing.css("td")[3].children.map(&:text).compact_blank.join(" "),
        url: URL
      }

      rooms_number = listing.css("td")[1].text
      properties.merge!(rooms_number: Integer(rooms_number)) if rooms_number.present?

      Apartment.new(
        external_id: "bbg-#{listing.css('td')[4].text}",
        properties: properties
      )
    end
  end
end
