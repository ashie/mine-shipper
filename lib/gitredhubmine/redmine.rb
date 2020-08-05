require 'net/https'
require 'uri'
require 'json'

module GitRedHubMine
  class Redmine
    def initialize(base_url, api_key = nil)
      @base_url = base_url
      @api_key = api_key
    end

    def redmine_api_request(path, params = {}, method = :get)
      url = "#{@base_url}/#{path}"
      uri = URI.parse(url)

      case method
      when :get
        req = Net::HTTP::Get.new(uri.request_uri)
      when :post
        req = Net::HTTP::Post.new(uri.request_uri)
      when :put
        req = Net::HTTP::Put.new(uri.request_uri)
      end
      req["Content-Type"] = "application/json"
      req['X-Redmine-API-Key'] = @api_key
      req.body = params.to_json

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.request(req)
    end

    def custom_fields(params = {})
      response = redmine_api_request("custom_fields.json", params)
      JSON.parse(response.body)["custom_fields"]
    end

    def get_custom_field_id(custom_field_name)
      fields = custom_fields
      field = fields.find do |field|
        field["name"] == custom_field_name
      end
      field["id"]
    end

    def issues(params = {})
      response = redmine_api_request("issues.json", params)
      JSON.parse(response.body)["issues"]
    end

    def issue(id)
      params = {
        include: "journals"
      }
      response = redmine_api_request("issues/#{id}.json", params)
      JSON.parse(response.body)["issue"]
    end

    def get_issues_by_custom_field(field_name, field_value)
      custom_field_id = get_custom_field_id(field_name)
      search_options = {
        "cf_#{custom_field_id}".to_sym => field_value,
        :status_id => '*',
        :sort => 'id',
        :limit => 1,
      }
      issues(search_options)
    end
  end
end
