require 'csv'
require 'json'
require 'ndr_import/mapper'

class Handler
  include NdrImport::Mapper

  MAPPING = YAML.safe_load(<<~YML).freeze
    - column: column_one
      mappings:
      - field: field_one
        validates:
          presence: true
    - column: column_two
      mappings:
      - field: field_two
  YML

  def run(body, headers)
    response_headers = { 'content-type' => 'application/json' }
    body = CSV.parse(body).map { |line| mapped_line(line, MAPPING) }

    return body.to_json, response_headers, 200
  rescue => e
    return { error: e.class, message: e.message }.to_json, response_headers, 400
  end
end
