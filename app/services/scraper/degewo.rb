# frozen_string_literal: true

module Scraper
  class Degewo
    BASE_URL = "https://immosuche.degewo.de"
    # rubocop:disable Layout/LineLength
    LIST_URL = "#{BASE_URL}/de/search.json?utf8=%E2%9C%93&property_type_id=1&categories%5B%5D=1&wbs_required=0&order=rent_total_without_vat_asc".freeze
    # rubocop:enable Layout/LineLength

    def call
      follow(LIST_URL).map do |listing|
        Apartment.new(
          external_id: "degewo-#{url(listing)}",
          properties: {
            address: listing.fetch("full_address"),
            url: url(listing),
            rooms_number: Integer(listing.fetch("number_of_rooms").match(/(\d+) Zimmer/)[1]),
            wbs: listing.fetch("wbs_required")
          }
        )
      end
    end

    private

    attr_accessor :request

    def follow(url)
      response = Typhoeus.get(url)
      raise StandardError.new response.return_code unless response.success?
      json = JSON.parse(response.body)
      head = json.fetch("immos")
      next_page_url = json.fetch("pagination").fetch("next_page", nil)

      if next_page_url
        head + follow("#{BASE_URL}#{next_page_url}")
      else
        head
      end
    end

 

    def url(listing)
      "#{BASE_URL}#{listing.fetch('property_path')}"
    end
  end
end
