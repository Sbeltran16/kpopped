require 'nokogiri'
require 'open-uri'
require 'uri'

class KpopScraper
  BASE_URL = 'https://kpopping.com'

  def initialize(group_name)

    formatted_group_name = group_name.strip.gsub(' ', '-')
    @group_url = "#{BASE_URL}/profiles/group/#{group_name}"
  end

  def scrape_group_data
    begin
      uri = URI.parse(@group_url)
      doc = Nokogiri::HTML(uri.open)
    rescue OpenURI::HTTPError => e
      puts "HTTP Error: #{e.message}"
      return { error: "Failed to fetch data" }
    rescue URI::InvalidURIError => e
      puts "Invalid URI Error: #{e.message}"
      return { error: "Invalid URL format" }
    rescue StandardError => e
      puts "Error: #{e.message}"
      return { error: "An error occurred" }
    end

    {
      profile_data: scrape_profile_data(doc),
      group_pose_image: scrape_group_pose_image(doc),
      discography: scrape_discography(doc),
      group_latest_pictures: scrape_latest_images(doc),
      members: scrape_members(doc),
      group_stats: scrape_group_stats(doc)
    }
  end

  private

  def scrape_profile_data(doc)
    {
      name: doc.css('figcaption h1').text.strip
    }
  end

  def scrape_group_pose_image(doc)
    relative_url = doc.css('figure.group-pose img').attr('src')&.value
    prepend_base_url(relative_url)
  end

  def scrape_discography(doc)
    doc.css('#group-discography .album-covers .item').map do |album|
      {
        title: album.css('h3').text.strip,
        release_date: album.css('time').attr('datetime')&.value,
        tracks: album.css('p').text.strip.to_i,
        cover_image: prepend_base_url(album.css('figure img').attr('src')&.value)
      }
    end
  end

  def scrape_latest_images(doc)
    doc.css('#group-latest-pictures .matrix img').map do |img|
      prepend_base_url(img.attr('src'))
    end
  end

  def scrape_members(doc)
    doc.css('.members .member').map do |member|
      {
        name: member.css('span strong').text.strip,
        image: prepend_base_url(member.css('img').attr('src')&.value)
      }
    end
  end

  def scrape_group_stats(doc)
    stats = {}
    doc.css('.data-grid.data-grid-1.data-grid-auto .cell').each do |cell|
      name = cell.css('.name').text.strip.gsub(':', '')
      value = cell.css('.value').text.strip
      stats[name] = value
    end
    stats
  end

  def prepend_base_url(relative_url)
    return nil unless relative_url

    # Check if the URL is already absolute
    return relative_url if URI.parse(relative_url).absolute?

    # Combine the base URL with the relative URL
    URI.join(BASE_URL, relative_url).to_s
  end
end


