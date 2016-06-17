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

  def is_empty?(cell)
    ['', '-', '_'].include?(cell.to_s.strip)
  end

  # Converts raw CSV data into an Array of OCD ID Hashes.
  #
  # @param raw_csv_data [String] the raw CSV data to convert to OCD IDs.
  # @param mapping [Hash, {}] mapping of column_we_want => column_in_csv symbols.
  #   Valid column names are `:region`, `:subregion`, `:district` and `:constituency`.
  # @return [Array] each object in the array is a hash with `:id` and `:name` props.
  def ocd_ids_from_csv(raw_csv_data, mapping = {})
    csv = CSV.parse(raw_csv_data, headers: true, header_converters: :symbol)
    ocd_ids = Set.new

    csv.each do |r|
      region = r[mapping.fetch(:region, :region)]
      next if is_empty?(region)
      ocd_ids << {
        id: id_for(region: region),
        name: region.strip
      }

      subregion = r[mapping.fetch(:subregion, :subregion)]
      next if is_empty?(subregion)
      ocd_ids << {
        id: id_for(region: region, subregion: subregion),
        name: subregion.strip
      }

      district = r[mapping.fetch(:district, :district)]
      next if is_empty?(district)
      ocd_ids << {
        id: id_for(region: region, subregion: subregion, district: district),
        name: district.strip
      }

      constituency = r[mapping.fetch(:constituency, :constituency)]
      next if is_empty?(constituency)
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
