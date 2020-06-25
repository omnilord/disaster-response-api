json.extract! question, :id, :body, :resource_type, :required, :private, :retired, :created_by, :updated_by, :created_at, :updated_at
json.url question_url(question, format: :json)
