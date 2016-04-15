require 'bundler/setup'
require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'pry'

csv_url = 'https://docs.google.com/spreadsheets/d/1LetNFNq6ovg4bbq-Whze0Q06CYSpNqpRIzSUb9yVtw4/export?format=csv'

csv = CSV.parse(open(csv_url).read, headers: true, header_converters: :symbol)

ocd_ids = []

base_id = "ocd-division/country:ng"

def idify(name)
  name.to_s.downcase.gsub(/[[:space:]]+/, '_')
end

csv.each do |r|
  if r[:arearegion]
    ocd_ids << {
      id: "#{base_id}/region:#{idify(r[:arearegion])}",
      name: r[:arearegion]
    }
  end

  if r[:areasub_region]
    ocd_ids << {
      id: "#{base_id}/region:#{idify(r[:arearegion])}/subregion:#{idify(r[:areasub_region])}",
      name: r[:areasub_region]
    }
  end

  if r[:areadistrict]
    ocd_ids << {
      id: "#{base_id}/region:#{idify(r[:arearegion])}/subregion:#{idify(r[:areasub_region])}/district:#{idify(r[:areadistrict])}",
      name: r[:areadistrict]
    }
  end

  if r[:areaconstituency]
    ocd_ids << {
      id: "#{base_id}/region:#{idify(r[:arearegion])}/subregion:#{idify(r[:areasub_region])}/district:#{idify(r[:areadistrict])}/constituency:#{idify(r[:areaconstituency])}",
      name: r[:areaconstituency]
    }
  end
end

ocd_ids.each do |row|
  ScraperWiki.save_sqlite([:id], row)
end
