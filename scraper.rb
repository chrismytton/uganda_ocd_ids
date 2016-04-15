require 'bundler/setup'
require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'pry'

csv_url = 'https://docs.google.com/spreadsheets/d/1LetNFNq6ovg4bbq-Whze0Q06CYSpNqpRIzSUb9yVtw4/export?format=csv'

csv = CSV.parse(open(csv_url).read, headers: true, header_converters: :symbol)

ocd_ids = []

def idify(name)
  name.downcase.gsub(/[[:space:]]+/, '_')
end

def id_for(parts)
  "ocd-division/country:ng/" + parts.map { |type, value| [type, idify(value)].join(':') }.join('/')
end

csv.each do |r|
  next unless r[:arearegion]
  ocd_ids << {
    id: id_for(region: r[:arearegion]),
    name: r[:arearegion]
  }

  next unless r[:areasub_region]
  ocd_ids << {
    id: id_for(region: r[:arearegion], subregion: r[:areasub_region]),
    name: r[:areasub_region]
  }

  next unless r[:areadistrict]
  ocd_ids << {
    id: id_for(region: r[:arearegion], subregion: r[:areasub_region], district: r[:areadistrict]),
    name: r[:areadistrict]
  }

  next unless r[:areaconstituency]
  ocd_ids << {
    id: id_for(region:r[:arearegion], subregion: r[:areasub_region], district: r[:areadistrict], constituency: r[:areaconstituency]),
    name: r[:areaconstituency]
  }
end

ocd_ids.each do |row|
  ScraperWiki.save_sqlite([:id], row)
end
