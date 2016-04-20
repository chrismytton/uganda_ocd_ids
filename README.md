# Uganda OCD Division IDs

This repository contains [OCD Division IDs](http://opencivicdata.readthedocs.org/en/latest/proposals/0002.html) for Uganda.

## Usage

The identifiers can be found in `identifiers/country-ug.csv`. They follow the standard OCD Division ID format and have an `id` and a `name` column.

## Regenerating IDs from the Google Spreadsheet of Ugandan data

    git clone https://github.com/theyworkforyou/uganda_ocd_ids
    cd uganda_ocd_ids
    bundle exec rake generate_csv
