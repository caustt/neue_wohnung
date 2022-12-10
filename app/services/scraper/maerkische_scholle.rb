# frozen_string_literal: true

module Scraper
  class MaerkischeScholle

    URL = "https://www.maerkische-scholle.de/wohnungsangebote.html"

    def get_requests()
      self.request = Typhoeus::Request.new(URL)
    end

    def call
      raise StandardError.new request.response.return_code unless request.response.success?
      page = Nokogiri::HTML(request.response.body)
      page.css("#main .ce_text").drop(1).map { |listing| parse(listing) }
    end

    private

    attr_accessor :request

    def parse(listing)
      Apartment.new(
        external_id: "maerkische-scholle-#{listing.css('a').attribute('href').value}",
        properties: {
          address: listing.css("p strong").first.children.first.text,
          url: URL,
          rooms_number: Integer(listing.css("h2").text.match(/(\d+)\sZimmer/)[1]),
          wbs: listing.css("h2").text.include?("WBS")
        }
      )
    end
  end
end
