require 'net/https'
require 'uri'
require 'json'

module GitRedHubMine
  class Redmine
    class Issue
      attr_reader :comments

      def initialize(json)
        @json = json
        @comments = []
        @json["journals"].each do |journal|
          next if journal["notes"].empty?
          @comments << Comment.new(journal)
        end
      end

      def id
        @json["id"]
      end

      def title
        @json["subject"]
      end
    end

    class Comment
      def initialize(json)
        @json = json
      end

      def body
        @json["notes"]
      end

      def created_at
        Time.parse(@json["created_on"])
      end
    end

    def initialize(base_url, api_key = nil)
      @base_url = base_url
      @api_key = api_key
    end

    def api_request(path, params = {}, method = :get)
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
      response = api_request("custom_fields.json", params)
      JSON.parse(response.body)["custom_fields"]
    end

    def custom_field_id(custom_field_name)
      fields = custom_fields
      field = fields.find do |field|
        field["name"] == custom_field_name
      end
      field["id"]
    end

    def issues(params = {})
      response = api_request("issues.json", params)
      issues_json = JSON.parse(response.body)["issues"]
      issues = []
      issues_json.each do |issue_json|
        id = issue_json["id"]
        issues << issue(id)
      end
      issues
    end

    def issue(id)
      params = {
        include: "journals"
      }
      response = api_request("issues/#{id}.json", params)
      issue_json = JSON.parse(response.body)["issue"]
      Issue.new(issue_json)
    end

    def issues_by_custom_field(field_name, field_value, limit: nil)
      cf_id = custom_field_id(field_name)
      search_options = {
        "cf_#{cf_id}".to_sym => field_value,
        :status_id => '*',
        :sort => 'id',
        :limit => limit,
      }
      issues(search_options)
    end

    def issue_by_custom_field(field_name, field_value)
      issues = issues_by_custom_field(field_name, field_value, limit: 1)
      issues.empty? ? nil : issues.first
    end
  end
end
