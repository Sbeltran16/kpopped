require 'nokogiri'
require 'open-uri'
require 'uri'
require 'concurrent-ruby'

class KpopScraper
  BASE_URL = 'https://kpopping.com'
  DBKPOP_BASE_URL = 'https://dbkpop.com/group'

  def initialize(group_name)
    formatted_group_name = group_name.strip.gsub(/\s+/, '-').downcase
    @group_url = "#{BASE_URL}/profiles/group/#{formatted_group_name}"
    @dbkpop_url = "#{DBKPOP_BASE_URL}/#{formatted_group_name}"
  end

  def scrape_data
    # Fetch the data concurrently to save time
    group_data_future = Concurrent::Future.execute { fetch_and_parse(@group_url) }
    latest_images_future = Concurrent::Future.execute { fetch_latest_images }

    begin
      doc = group_data_future.value # Waits for the result of fetching group data

      {
        profile_data: scrape_profile_data(doc),
        group_pose_image: scrape_group_pose_image(doc),
        discography: scrape_discography(doc),
        group_latest_pictures: latest_images_future.value,
        members: scrape_members(doc),
        group_stats: scrape_group_stats(doc)
      }
    rescue StandardError => e
      puts "Error: #{e.message}"
      { error: "An error occurred while fetching data" }
    end
  end

  private

  def fetch_and_parse(url)
    doc = Nokogiri::HTML(URI.open(url))
    doc
  rescue OpenURI::HTTPError, URI::InvalidURIError => e
    puts "Fetch error: #{e.message}"
    Nokogiri::HTML('') # Return an empty document on failure
  end

  def fetch_latest_images
    fetch_and_parse(@dbkpop_url).css('.foogallery .fg-item .fg-thumb').map { |img| img['href'] }
  end

  def scrape_profile_data(doc)
    {
      name: doc.at_css('figcaption h1')&.text&.strip || 'Unknown'
    }
  end

  def scrape_group_pose_image(doc)
    relative_url = doc.at_css('figure.group-pose img')&.attr('src')
    prepend_base_url(relative_url)
  end

  def scrape_discography(doc)
    doc.css('#group-discography .album-covers .item').map do |album|
      {
        title: album.at_css('h3')&.text&.strip || 'Unknown',
        release_date: album.at_css('time')&.attr('datetime'),
        tracks: album.at_css('p')&.text&.strip.to_i,
        cover_image: prepend_base_url(album.at_css('figure img')&.attr('src'))
      }
    end
  end

  def scrape_members(doc)
    doc.css('.members .member').map do |member|
      {
        name: member.at_css('span strong')&.text&.strip || 'Unknown',
        image: prepend_base_url(member.at_css('img')&.attr('src')),
        profile_url: member.attr('href')
      }
    end
  end

  def scrape_group_stats(doc)
    stats = {}
    doc.css('.data-grid.data-grid-1.data-grid-auto .cell').each do |cell|
      name = cell.at_css('.name')&.text&.strip&.gsub(':', '') || 'Unknown'
      value = cell.at_css('.value')&.text&.strip || 'Unknown'
      stats[name] = value
    end
    stats
  end

  def prepend_base_url(relative_url)
    return nil unless relative_url

    URI.parse(relative_url).absolute? ? relative_url : URI.join(BASE_URL, relative_url).to_s
  end
end
