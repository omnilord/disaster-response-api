json.extract! shelter, *%i[id name address city state county postal_code notes longitude latitude]
json.shelter shelter.name
json.source shelter.latest_data_source
json.pets ''
json.pet_notes ''
json.phone shelter.primary_phone
stripped_phone = (shelter.primary_phone || '').gsub(/\D/, '')
json.cleanPhone stripped_phone.match?(/^\d{10}$/) ? stripped_phone : 'badphone'

udatetime = shelter.updated_at.in_time_zone('Central Time (US & Canada)').rfc3339
json.updated_at udatetime
json.updatedAt udatetime
json.last_updated udatetime
