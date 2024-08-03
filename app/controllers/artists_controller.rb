class ArtistsController < ApplicationController
  def show
    name = params[:name]
    type = params[:type] == 'idol' ? :idol : :group
    scraper = type == :idol ? IdolScraper.new(name) : KpopScraper.new(name)
    data = scraper.scrape_data
    render json: data
  end
end