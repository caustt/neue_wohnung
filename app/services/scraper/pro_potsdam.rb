# frozen_string_literal: true

module Scraper
    class ProPotsdam
      BASE_URL = "https://propotsdam-kundenportal.easysquare.com"
      # rubocop:disable Layout/LineLength 
      LIST_URL = "#{BASE_URL}/prorex/xmlforms?application=ESQ_IA_REOBJ&sap-client=511&command=action&name=boxlist&api=6.153&head-oppc-version=6.153.17".freeze
      # rubocop:enable Layout/LineLength
      AUTH_URL = "https://propotsdam-kundenportal.easysquare.com/propotsdam-kundenportal/api5/authenticate?api=6.153&sap-language=de"
      
      def get_requests()
        body = { "sap-ffield_b64": "dXNlcj1ERU1PJnBhc3N3b3JkPXByb21vczE3" }
        self.request = Typhoeus::Request.new(AUTH_URL, method: :post, body: body)
      end
  
      def call
        raise StandardError.new request.response.return_code unless request.response.success?
        authentication_response = request.response
        cookie_hash = HTTParty::CookieHash.new
        authentication_response.headers_hash['set-cookie'].each { |c| cookie_hash.add_cookies(c) }
        page = Nokogiri::XML(Typhoeus.get(LIST_URL, :headers =>  {'Cookie' => cookie_hash.to_cookie_string }).body)

        page
          .css("head")
          .select { |listing| apartment?(listing) }
          .map { |listing| parse(listing) }
      end
  
      private
  
      attr_accessor :request
  
      def apartment?(listing)
        listing.text.exclude?("Stellplatz") && listing.text.exclude?("Gewerbe")
      end
  
      def parse(listing)
        Apartment.new(
          external_id: "pro-potsdam-#{id(listing)}",
          properties: {
            address: "#{listing.css("title").text}, Potsdam",
            url: url(),
            rooms_number: rooms_number(listing),
            warm_rent: warm_rent(listing)
          }
        )
      end

      def id(listing)
        listing.css("originalId").text
      end
  
      def url()
        "#{BASE_URL}/propotsdam-kundenportal/index.html"
      end
  
      def rooms_number(listing)
        listing.css("[title=Zimmer]").text[1..-2].to_i
      end

      def warm_rent(listing)
        listing.css("[title=Gesamtmiete]").text[1..-3].to_i
      end
    end
  end
  