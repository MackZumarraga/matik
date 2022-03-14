require 'google/apis/slides_v1'

body = Google::APIClient::SlidesV1::Presentation.new
body.title = title
presentation = slides_service.create_presentation(body)
puts "Created presentation with ID: #{presentation.presentation_id}"