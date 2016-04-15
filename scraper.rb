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
    id: r[:test_area_id],
    name: r[:areaconstituency] || r[:areadistrict] || r[:areasub_region] || r[:arearegion]
  }
end

rows.compact.uniq.map { |r| r[:id] }.each do |r|
  parts = r.split('/')
  (parts.size - 1).downto(2).each do |n|
    rows << { id: parts.take(n).join('/'), name: nil }
  end
end

rows.compact.reject { |r| r[:name] && r[:name].end_with?('Youth') }.uniq { |r| r[:id] }.each do |row|
  ScraperWiki.save_sqlite([:id], row)
end
