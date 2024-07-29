class ArtistsController < ApplicationController
  def show
    group_name = params[:name]
    scraper = KpopScraper.new(group_name)
    data = scraper.scrape_group_data
    render json: data
  end
end
