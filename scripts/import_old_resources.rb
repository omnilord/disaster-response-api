#
# This script imports resource (currently only Shelters) from the old API
# into the resources table.
#
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!                                                          !!
# !!  Take care, this script DOES NOT PERFORM DEDUPLICATIONS  !!
# !!                                                          !!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Example for how to run this script:
#
#     bundle exec rails runner scripts/import_old_resources.rb state:LA
#
# Any of the fields in the KEYS constant below can be used as an exact match
# filter on which shelters will be processed _after_ all shelters are pulled.
#

require 'net/http'
require 'json'

# CONSTANTS for various actual information

TARGET = 'shelters' # TODO: ARGV[0] in a predefined list, shelters, or pods, etc.
API_URL = "https://api.hurricane-response.org/api/v1/#{TARGET}/"
KEYS = {
  'shelters' => %w[accepting shelter address city state county zip phone updated_by notes volunteer_needs longitude latitude supply_needs source google_place_id special_needs id archived pets pets_notes needs updated_at updatedAt last_updated cleanPhone].freeze
}[TARGET]
KV_REGEX = /(?<key>\w+):(?<value>\w+)/
FILTERS = ARGV.grep(KV_REGEX).map do |arg|
  kv = KV_REGEX.match(arg).named_captures
  kv['key'].downcase!
  raise ArgumentError, "#{kv['key']} is an invalid field key." unless KEYS.include?(kv['key'])
  kv
end.compact.freeze
FIELDS_MAP = {
  # remote key => local key
  # local key started with '!' means to invert the binary
  'shelters' => {
    '!archived' => 'active',
    'shelter' => 'name',
    'address' => 'address',
    'city' => 'city',
    'county' => 'county',
    'state' => 'state',
    'zip' => 'postal_code',
    'phone' => 'primary_phone',
    'notes' => 'notes',
    'source' => 'latest_data_source',
  }.freeze
}[TARGET]
TMP_DATA_FILE = File.join(Rails.root, 'scripts', "#{TARGET}.data.json")


# Utility functions

def ensure_system_user
  @system_user ||= User.where(email: 'system@localhost.localdomain').first_or_create do |user|
    user.email = 'system@localhost.localdomain'
    user.password = 256.times.map { ('1'..'z').to_a.sample }.join
    user.admin = true
    user.real_name = 'System'
    user.location = 'localhost.localdomain'
  end
end

def save_data(text)
  File.open(TMP_DATA_FILE, 'wb') do |fh|
    fh << text
  end
  text
end

def fetch_data
  uri = URI(API_URL)
  uri.query = URI.encode_www_form({ exporter: 'all' })
  res = Net::HTTP.get_response(uri)

  if res.is_a?(Net::HTTPSuccess)
    save_data(res.body)
  end
end

def get_data
  return File.read(TMP_DATA_FILE) if File.exist?(TMP_DATA_FILE)
  fetch_data
end

def select?(item)
  FILTERS.all? { |filter| item[filter['key']].to_s.downcase == filter['value'].to_s.downcase }
end

def sift_data
  JSON.parse(get_data)[TARGET].each do |item|
    yield item if select?(item)
  end
end

def map_data(item)
  data = FIELDS_MAP.reduce({}) do |m, (s, d)|
    if s.start_with? '!'
      m[d] = !item[s[1..]]
    else
      m[d] = item[s]
    end
    m
  end
  data['resource_type'] = TARGET.singularize
  data['coords'] = "SRID=4326;POINT(#{item['longitude']} #{item['latitude']})"
  data['active'] = true

  data
end


# MAIN

Current.user = ensure_system_user

sift_data do |item|
  data = map_data(item)
  draft = Draft.new(draftable_type: Resource, data: data)
  if draft.save
    if draft.approve
      obj = draft.draftable
      puts "#{obj.name} has been saved, #{obj.id}."
    else
      puts 'Approval failures:'
      puts draft.errors.inspect
    end
  else
    puts 'Save failures:'
    puts draft.errors.inspect
  end
end

File.delete(TMP_DATA_FILE) if File.exist?(TMP_DATA_FILE)





__END__
                                            Table "public.resources"
       Column       |            Type             | Collation | Nullable |                Default
--------------------+-----------------------------+-----------+----------+---------------------------------------
 id                 | bigint                      |           | not null | nextval('resources_id_seq'::regclass)
 name               | text                        |           | not null |
 resource_type      | text                        |           | not null |
 address            | text                        |           |          |
 city               | text                        |           |          |
 county             | text                        |           |          |
 state              | text                        |           |          |
 postal_code        | text                        |           |          |
 primary_phone      | text                        |           |          |
 secondary_phone    | text                        |           |          |
 private_contact    | text                        |           |          |
 private_email      | text                        |           |          |
 private_phone      | text                        |           |          |
 private_notes      | text                        |           |          |
 notes              | text                        |           |          |
 latest_data_source | text                        |           |          |
 current_draft_id   | bigint                      |           | not null |
 active             | boolean                     |           |          | true
 created_by_id      | bigint                      |           |          |
 updated_by_id      | bigint                      |           |          |
 created_at         | timestamp without time zone |           | not null |
 updated_at         | timestamp without time zone |           | not null |
 coords             | geography(Point,4326)       |           | not null |
 country            | text                        |           |          |
Indexes:
    "resources_pkey" PRIMARY KEY, btree (id)
    "index_resources_on_created_by_id" btree (created_by_id)
    "index_resources_on_current_draft_id" btree (current_draft_id)
    "index_resources_on_name" btree (name)
    "index_resources_on_resource_type" hash (resource_type)
    "index_resources_on_updated_by_id" btree (updated_by_id)
Foreign-key constraints:
    "fk_rails_1fda166c62" FOREIGN KEY (created_by_id) REFERENCES users(id)
    "fk_rails_b42372633f" FOREIGN KEY (updated_by_id) REFERENCES users(id)
    "fk_rails_eeb713e646" FOREIGN KEY (current_draft_id) REFERENCES drafts(id)
Referenced by:
    TABLE "answers" CONSTRAINT "fk_rails_fcbbfa0942" FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE



TODO: a question builder for these fields:

# QUESTIONS = %w[volunteer_needs supply_needs source special_needs pets pets_notes needs].freeze
