require 'net/https'
require 'json'

def http uri
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  http
end

def select_http_method http_method
  case http_method
  when :get
    Net::HTTP::Get
  when :post
    Net::HTTP::Post
  else
    raise ArgumentError, 'Http method must be get or post'
  end
end

def request method, uri, data = {}
  request = select_http_method(method).new(uri.request_uri)

  request['Authorization'] = "Bearer #{ENV['LIFX_APP_TOKEN']}"
  request.set_form_data(data) unless data.empty?
  http(uri).request(request)
end

uri = URI('https://api.lifx.com/v1/lights/all')
response = request :get, uri
id = JSON.parse(response.body).first['id']

uri = URI("https://api.lifx.com/v1/lights/#{id}/effects/breathe")
response = request :post, uri, {'color' => 'blue'}
