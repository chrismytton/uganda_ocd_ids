require 'bundler/setup'
require 'open-uri'
require 'csv'
require 'pry'
require 'set'

desc 'Generate a CSV file of Uganda OCD IDs from the Google Spreadsheet'
task :generate_csv do
  def idify(name)
    name.downcase.gsub(/[[:space:]]+/, '_').gsub('/', '~')
  end

  def id_for(parts)
    "ocd-division/country:ug/" + parts.map { |type, value| [type, idify(value)].join(':') }.join('/')
  end

  csv_url = 'https://docs.google.com/spreadsheets/d/1LetNFNq6ovg4bbq-Whze0Q06CYSpNqpRIzSUb9yVtw4/export?format=csv'

  csv = CSV.parse(open(csv_url).read, headers: true, header_converters: :symbol)

  ocd_ids = Set.new

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

  out = CSV.generate do |csv|
    csv << ocd_ids.first.keys
    ocd_ids.each { |row| csv << row.values }
  end

  filename = 'identifiers/country-ug.csv'

  File.write(filename, out)
  puts "Created #{filename}"
end

task default: :generate_csv
