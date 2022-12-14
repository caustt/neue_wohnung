# frozen_string_literal: true

module Scraper
  class KarlMarx
    URL = "https://www.wgkarlmarx.de"
    LIST_URL = "#{URL}/fuer-wohnungssucher"

    def get_requests()
      self.request = Typhoeus::Request.new(URL, :followlocation => true)
    end

    def call
      raise StandardError.new request.response.return_code unless request.response.success?
      page = Nokogiri::HTML(request.response.body)
      page
        .css(".immo-object.card")
        .select { |listing| apartment?(listing)}
        .map { |listing| parse(listing) }
    end

    private

    attr_accessor :request

    def apartment?(listing)
      listing.text.downcase.exclude?("stellplatz") && listing.text.downcase.exclude?("gewerbe")
    end

    def parse(listing)
      Apartment.new(
        external_id: "karlmarx-#{url(listing)}",
        properties: {
          address: listing.css('.location').text.strip.split(/[\s]{2,}/).join(", "),
          url: url(listing),
          warm_rent: warm_rent(listing),
          rooms_number: Integer(listing.css('.rooms .number').text.strip)
        }
      )
    end

    def warm_rent(listing)
      matched_data = listing.css('.price .number').text.strip.split()[0]
      BigDecimal(matched_data.gsub(",", "."))
    end

    def url(listing)
      "#{URL}#{listing.css('a.card-link').attribute('href').value}"
    end
  end
end
