# frozen_string_literal: true

class ScrapeAll
  def initialize(
    scrapers: [
      Scraper::Bbg.new,
      Scraper::Charlotte.new,
      Scraper::Degewo.new,
      Scraper::Dpf.new,
      Scraper::EwgPankow.new,
      Scraper::Gesobau.new,
      Scraper::Gewobag.new,
      Scraper::Howoge.new,
      Scraper::MaerkischeScholle.new,
      Scraper::Mlbaugenossen.new,
      Scraper::NeuesBerlin.new,
      Scraper::StadtUndLand.new,
      Scraper::Vaterland.new,
      Scraper::Vbveg.new,
      Scraper::WbgFriedrichshain.new,
      Scraper::WbgHub.new,
      Scraper::WbgZentrum.new,
      Scraper::Wbm.new,
      Scraper::ProPotsdam.new,
      Scraper::KarlMarx.new
    ],
    bugsnag_client: Bugsnag
  )
    self.scrapers = scrapers
    self.bugsnag_client = bugsnag_client
  end

  def call
   hydra = Typhoeus::Hydra.new
    scrapers.map do |scraper|
     hydra.queue(scraper.get_requests) if defined? scraper.get_requests
    end
    hydra.run
    scrapers.map do |scraper|
      scraper.call
    rescue Errno::ECONNREFUSED, Errno::ECONNRESET, OpenSSL::SSL::SSLError,
           Net::OpenTimeout, Net::ReadTimeout, SocketError => e
      bugsnag_client.notify(e) do |report|
        report.severity = "warning"
      end

      []
    rescue StandardError => e
      bugsnag_client.notify(e)
      []
    end.flatten
  end

  private

  attr_accessor :scrapers, :bugsnag_client
end
