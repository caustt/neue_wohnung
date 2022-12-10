# frozen_string_literal: true

module Scraper
  class Dpf
    URL = "https://www.dpfonline.de/interessenten/immobilien/"

    def get_requests()
      self.request = Typhoeus::Request.new(URL)
    end

    def call
      raise StandardError.new request.response.return_code unless request.response.success?
      page = Nokogiri::HTML(request.response.body)
      page.css(".immo-archive-cc").map { |listing| parse(listing) }
    end

    private

    
    attr_accessor :request

    def parse(listing)
      Apartment.new(
        external_id: "dpf-#{url(listing)}",
        properties: {
          address: listing.css(".uk-list li").first.text.strip,
          url: url(listing),
          rooms_number: rooms_number(listing),
          wbs: listing.css("a").text.include?("WBS")
        }
      )
    end

    def url(listing)
      listing.css("a").attribute("href").value
    end

    def rooms_number(listing)
      element_with_data = listing.css(".uk-width-medium-1-4").find do |element|
        element.text.match(/(\d*).*Zimmer/)
      end

      Float(element_with_data.at(".immo-data").text.strip).round(half: :down)
    end
  end
end
