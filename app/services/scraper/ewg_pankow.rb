# frozen_string_literal: true

module Scraper
  class EwgPankow
    URL = "https://www.ewg-pankow.de/wohnen/"

    def get_requests()
      self.request = Typhoeus::Request.new(URL)
    end

    def call
      raise StandardError.new request.response.return_code unless request.response.success?
      page = Nokogiri::HTML(request.response.body)
      container = page.css(".elementor-posts-container").first

      return [] if container.text.include?("Aktuell ist leider kein Wohnungsangebot verfügbar")

      container.css(".elementor-post.type-wohnungen").map { |listing| parse(listing) }
    end

    private

    attr_accessor :request

    def parse(listing)
      Apartment.new(
        external_id: external_id(listing),
        properties: {
          address: address(listing),
          url: url(listing),
          rooms_number: rooms_number(listing)
        }
      )
    end

    def external_id(listing)
      post_id = listing.attr("class").match(/post-(\d*).*/)[1]
      "ewg-pankow-#{post_id}"
    end

    def address(listing)
      listing.css(".elementor-post__title").text.strip.gsub(/(\d*).*Zimmer,\s/, "")
    end

    def url(listing)
      listing.css(".elementor-post__read-more").attr("href").value
    end

    def rooms_number(listing)
      Integer(listing.css(".elementor-post__title").text.strip.match(/(\d*).*Zimmer/)[1])
    end
  end
end
