require 'bundler/setup'
require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'pry'

csv_url = 'https://docs.google.com/spreadsheets/d/1LetNFNq6ovg4bbq-Whze0Q06CYSpNqpRIzSUb9yVtw4/export?format=csv'

csv = CSV.parse(open(csv_url).read, headers: true, header_converters: :symbol)

rows = csv.map do |r|
  next unless r[:test_area_id]
  {
    id: r[:test_area_id].gsub(/_+/, '_'),
    name: (r[:areaconstituency] || r[:areadistrict] || r[:areasub_region] || r[:arearegion]).gsub(/[[:space:]]+/, ' ')
  }
end

rows.compact.reject { |r| r[:name] && r[:name].end_with?('Youth') }.each do |row|
  ScraperWiki.save_sqlite([:id], row)
end
