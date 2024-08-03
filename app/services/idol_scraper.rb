require 'nokogiri'
require 'open-uri'
require 'uri'
require 'concurrent-ruby'

class IdolScraper
  BASE_URL = 'https://kpopping.com'
  DBKPOP_BASE_URL = 'https://dbkpop.com/idol'

  def initialize(idol_name)
    formatted_idol_name = idol_name.strip.gsub(' ', '-').downcase
    @idol_name = idol_name
    @idol_url = "#{BASE_URL}/profiles/idol/#{formatted_idol_name}"
    @dbkpop_url = "#{DBKPOP_BASE_URL}/#{formatted_idol_name}"
  end

  def scrape_data
    # Fetch the data concurrently to save time
    idol_data_future = Concurrent::Future.execute { fetch_and_parse(@idol_url) }
    dbkpop_images_future = Concurrent::Future.execute { fetch_dbkpop_latest_images }

    begin
      doc = idol_data_future.value # Waits for the result of fetching idol data

      {
        profile_data: scrape_profile_data(doc),
        pose_image: scrape_pose_image(doc),
        discography: scrape_discography(doc),
        latest_pictures: dbkpop_images_future.value,
        stats: scrape_stats(doc)
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

  def fetch_dbkpop_latest_images
    fetch_and_parse(@dbkpop_url).css('.foogallery .fg-item .fg-thumb').map { |img| img['href'] }
  end

  def scrape_profile_data(doc)
    {
      name: doc.css('section h1').text.strip
    }
  end

  def scrape_pose_image(doc)
    # Select the link element with the rel attribute set to "image_src"
    link_element = doc.at_css('link[rel="image_src"]')
    # Extract the href attribute from the link element
    image_url = link_element&.attr('href')
    # Return the URL or nil if the element or attribute is not found
    image_url ? prepend_base_url(image_url) : nil
  end

  def scrape_discography(doc)
    albums = doc.css('#idol-discography .album-covers .item').map do |album|
      {
        title: album.css('h3').text.strip,
        release_date: album.css('time').attr('datetime')&.value,
        tracks: album.css('p').text.strip.to_i,
        cover_image: prepend_base_url(album.css('figure img').attr('src')&.value)
      }
    end

    show_more_button = doc.at_css('#idol-discography .btn[data-ajax-url]')
    if show_more_button
      ajax_url = show_more_button['data-ajax-url']
      more_albums = fetch_additional_discography(ajax_url)
      albums.concat(more_albums)
    end

    albums
  end

  def fetch_additional_discography(ajax_url)
    uri = URI.join(BASE_URL, ajax_url)
    response = Net::HTTP.get(uri)
    json_data = JSON.parse(response)

    doc = Nokogiri::HTML(json_data['html'])
    doc.css('.album-covers .item').map do |album|
      {
        title: album.css('h3').text.strip,
        release_date: album.css('time').attr('datetime')&.value,
        tracks: album.css('p').text.strip.to_i,
        cover_image: prepend_base_url(album.css('figure img').attr('src')&.value)
      }
    end
  rescue StandardError => e
    puts "Error fetching additional discography: #{e.message}"
    []
  end

  def scrape_stats(doc)
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
