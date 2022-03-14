require 'google/apis/slides_v1'
require 'google/api_client/client_secrets'
require 'json'
require 'sinatra'
require 'securerandom'


enable :sessions
set :session_secret, 'setme'
set :port, 5000

get '/' do
  unless session.has_key?(:credentials)
    redirect to('/oauth_callback')
  end
  client_opts = JSON.parse(session[:credentials])
  auth_client = Signet::OAuth2::Client.new(client_opts)
  slides_service = Google::Apis::SlidesV1::SlidesService.new
  slides_service.authorization = auth_client

  send_file File.join('./index.html')
end

get '/oauth_callback' do
  client_secrets = Google::APIClient::ClientSecrets.load("./credentials.json")
  auth_client = client_secrets.to_authorization
  auth_client.update!(
    :scope => 'https://www.googleapis.com/auth/presentations',
    :redirect_uri => url('/oauth_callback'))
    
  if request['code'] == nil
    auth_uri = auth_client.authorization_uri.to_s
    redirect to(auth_uri)
  else
    auth_client.code = request['code']
    auth_client.fetch_access_token!
    auth_client.client_secret = nil
    session[:credentials] = auth_client.to_json
    redirect to('/')
  end
end

post '/post' do
  unless session.has_key?(:credentials)
    redirect to('/oauth_callback')
  end
  data = JSON.parse(request.body.read)

  client_opts = JSON.parse(session[:credentials])
  auth_client = Signet::OAuth2::Client.new(client_opts)
  slides_service = Google::Apis::SlidesV1::SlidesService.new
  slides_service.authorization = auth_client

  return nil if data["title"].empty? || data["name"].empty? || data["job"].empty? || data["company"].empty? || data["date"].empty? || data["logo"].empty?
  
  body = Google::Apis::SlidesV1::Presentation.new
  body.title = data["title"]
  presentation = slides_service.create_presentation(body)
 
  #ids
  presID = presentation.presentation_id
  titleSlide = presentation.slides[0]
  masterSlide = presentation.masters[0]
  masterTitleID = masterSlide.page_elements[0].object_id
  titleID = titleSlide.page_elements[0].object_id
  nameTextBox = 'nameTextBox'
  jobTextBox = 'jobTextBox'
  dateTextBox = 'dateTextBox'
  imageElement = 'imageElement'

  pt350 = {
    magnitude: '350',
    unit:      'PT'
  }

  pt100 = {
    magnitude: '100',
    unit: 'PT'
  }

  emu4M = {
  magnitude: '750000',
  unit:      'EMU'
  }

  #create main point slide with text
  requests = [
    #add shape for name
    {create_shape: {
      object_id_prop: nameTextBox,
      shape_type: 'TEXT_BOX',
      element_properties: {
        page_object_id: "simple-light-2",
        size:           {
          height: pt350,
          width:  pt350
        },
        transform:      {
          scale_x:     '1',
          scale_y:     '1',
          translate_x: '100',
          translate_y: '100',
          unit:        'PT'
      }}
    }},
    
    #add shape for job
    {create_shape: {
      object_id_prop: jobTextBox,
      shape_type: 'TEXT_BOX',
      element_properties: {
        page_object_id: "simple-light-2",
        size:           {
          height: pt350,
          width:  pt350
        },
        transform:      {
          scale_x:     '1',
          scale_y:     '1',
          translate_x: '100',
          translate_y: '120',
          unit:        'PT'
      }}
    }},

    #add shape for date
    {create_shape: {
      object_id_prop: dateTextBox,
      shape_type: 'TEXT_BOX',
      element_properties: {
        page_object_id: "simple-light-2",
        size:           {
          height: pt350,
          width:  pt350
        },
        transform:      {
          scale_x:     '1',
          scale_y:     '1',
          translate_x: '100',
          translate_y: '10',
          unit:        'PT'
      }}
    }},

    #add logo
    {create_image: {
      object_id_prop: imageElement,
      url: "https://logo.clearbit.com/#{(data["logo"]).downcase}",
      element_properties: {
        page_object_id: "simple-light-2",
        size:           {
          height: pt100,
          width:  pt100
        },
        transform:      {
          scale_x:     '1',
          scale_y:     '1',
          translate_x: '100',
          translate_y: '260',
          unit:        'PT'
        }
      }
    }},


    #add text details
    {insert_text: {object_id_prop: "i0", insertion_index: 0, text: data["company"]}},
    {insert_text: {object_id_prop: "i1", insertion_index: 0, text: data["title"]}},
    {insert_text: {object_id_prop: nameTextBox, insertion_index: 0, text: data["name"]}},
    {insert_text: {object_id_prop: jobTextBox, insertion_index: 0, text: data["job"]}},
    {insert_text: {object_id_prop: dateTextBox, insertion_index: 0, text: data["date"]}},
  ]

  # Execute the request.
  req = Google::Apis::SlidesV1::BatchUpdatePresentationRequest.new(requests: requests)
  
  response = slides_service.batch_update_presentation(presID, req)
  
  create_shape_response = response.replies[0].create_shape
  
  response = {
      "presentation": presentation,
      "date": "https://logo.clearbit.com/#{data["logo"]}",
      "presentationURL": "https://docs.google.com/presentation/d/#{presentation.presentation_id}",
  }

  JSON[response]
end


get '/login' do
  response = {"status": true}
  return JSON[response] if session.has_key?(:credentials)
end

get '/logout' do
  session.clear
  redirect '/'
end