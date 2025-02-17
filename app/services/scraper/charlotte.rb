# frozen_string_literal: true

module Scraper
  class Charlotte
    URL = "https://charlotte1907.de/wohnungsangebote/woechentliche-angebote"

    def get_requests()
      self.request = Typhoeus::Request.new(URL)
    end

    def call
      raise StandardError.new request.response.return_code unless request.response.success?
      page = Nokogiri::HTML(request.response.body)
      page
        .css(".apartment-lists > .image-block-content")
        .reject { |listing| only_for_members?(listing) }
        .map { |listing| parse(listing) }
    end

    private

     
    attr_accessor :request

    def only_for_members?(listing)
      listing.text.include?("Nur für Mitglieder")
    end

    def parse(listing)
      properties = {
        address: address(listing),
        url: URL,
        rooms_number: rooms_number(listing),
        wbs: listing.text.include?("WBS erforderl"),
        size: size(listing)
      }

      properties.merge!(rent(listing))

      Apartment.new(
        external_id: external_id(listing),
        properties: properties
      )
    end

    def address(listing)
      listing.css(".item-wrp")[1].text.gsub(/\s+/, " ").strip
    end

    def rooms_number(listing)
      Integer(listing.text.match(/Zimmer: (\d+)/)[1])
    end

    def size(listing)
      BigDecimal(
        listing.text.match(/Wohnfläche: (\d+,\d{2})/)[1].gsub(",", ".")
      ).round
    end

    def rent(listing)
      match_data = listing.text.match(
        /Gesamtmiete in Euro: (?<value>\d+,\d{2})(?: €)?\s(?<type>kalt|warm)/
      )
      value = BigDecimal(match_data[:value].gsub(",", "."))

      if match_data[:type] == "kalt"
        { cold_rent: value }
      else
        { warm_rent: value }
      end
    end

    def external_id(listing)
      "charlotte-#{listing.css('.header-green').text.match(/WOHNUNGS-Nr\.\s(.+)/)[1]}"
    end
  end
end
