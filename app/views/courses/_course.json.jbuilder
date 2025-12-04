json.extract! course, :id, :code, :name, :description, :credits, :capacity, :created_at, :updated_at
json.url course_url(course, format: :json)
