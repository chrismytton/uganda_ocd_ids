require 'bundler/setup'
require 'open-uri'
require 'csv'
require 'pry'
require 'set'

desc 'Generate a CSV file of Uganda OCD IDs from CSV file sources'
task :generate_csv do
  def idify(name)
    name.strip.downcase.gsub(/[[:space:]]+/, '_').gsub('/', '~')
  end

  def id_for(parts)
    "ocd-division/country:ug/" + parts.map { |type, value| [type, idify(value)].join(':') }.join('/')
  end

  def ocd_ids_from_csv(csv_data, mapping = {})
    csv = CSV.parse(csv_data, headers: true, header_converters: :symbol)
    ocd_ids = Set.new

    csv.each do |r|
      region = r[mapping.fetch(:region, :region)]
      next unless region
      ocd_ids << {
        id: id_for(region: region),
        name: region.strip
      }

      subregion = r[mapping.fetch(:subregion, :subregion)]
      next unless subregion
      ocd_ids << {
        id: id_for(region: region, subregion: subregion),
        name: subregion.strip
      }

      district = r[mapping.fetch(:district, :district)]
      next unless district
      ocd_ids << {
        id: id_for(region: region, subregion: subregion, district: district),
        name: district.strip
      }

      constituency = r[mapping.fetch(:constituency, :constituency)]
      next unless constituency
      next if ['-', '_'].include?(constituency)
      ocd_ids << {
        id: id_for(region: region, subregion: subregion, district: district, constituency: constituency),
        name: constituency.strip
      }
    end

    ocd_ids
  end

  google_raw_csv_data = open('https://docs.google.com/spreadsheets/d/1LetNFNq6ovg4bbq-Whze0Q06CYSpNqpRIzSUb9yVtw4/export?format=csv').read
  google_csv_mapping = { region: :arearegion, subregion: :areasub_region, district: :areadistrict, constituency: :areaconstituency }
  ocd_ids = ocd_ids_from_csv(google_raw_csv_data, google_csv_mapping)

  area_raw_csv_data = open('area_info.csv').read
  ocd_ids += ocd_ids_from_csv(area_raw_csv_data)

  out = CSV.generate do |csv|
    csv << ocd_ids.first.keys
    ocd_ids.sort_by { |ocd| ocd[:id] }.each { |row| csv << row.values }
  end

  filename = 'identifiers/country-ug.csv'

  File.write(filename, out)
  puts "Created #{filename}"
end

task default: :generate_csv
