# frozen_string_literal: true

module Scraper
  class Vbveg
    URL = "https://www.vbveg.de/wohnungsangebote.html"

    def get_requests()
      self.request = Typhoeus::Request.new(URL)
    end

    def call
      raise StandardError.new request.response.return_code unless request.response.success?
      page = Nokogiri::HTML(request.response.body)
      return [] if page.text.include?("Derzeit stehen keine Wohnungsangebote zur Verfügung")

      page.css("#article-127 .ce_text.block").map { |listing| parse(listing) }
    end

    private

    attr_accessor :request

    def parse(listing)
      rooms_number, address, wbs = parse_title(listing)

      Apartment.new(
        external_id: "vbveg-#{address}-#{warm_rent(listing)}",
        properties: {
          address: address,
          url: URL,
          rooms_number: rooms_number,
          wbs: wbs,
          warm_rent: warm_rent(listing)
        }
      )
    end

    def parse_title(listing)
      title = listing.css("h5").text
      match_data = title.match(/(\d+(,5)?)-Zimmerwohnung,\s(.*)/)
      rooms_number = Float(match_data[1].gsub(",", ".")).round(half: :down)
      rest = match_data[3]
      address = rest.gsub(" - Nur mit WBS", "")
      wbs = rest.include?("WBS")

      [rooms_number, address, wbs]
    end

    def warm_rent(listing)
      match_data = listing.css("p").text.match(/(\d+(,\d{2})?)\s€/)
      BigDecimal(match_data[1].gsub(",", "."))
    end
  end
end
