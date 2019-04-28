json.extract! event, :id, :name, :disaster_type, :content, :administrator,
                     :activated, :deactivated,:created_at, :updated_at
json.url event_url(event, format: :json)
