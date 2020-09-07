#
# Copyright (C) 2020 Takuro Ashie <ashie@clear-code.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'net/https'
require 'uri'
require 'json'
require_relative './issue_comment.rb'

module MineShipper
  class Redmine
    class Issue
      attr_reader :tracker, :id, :identifier, :title, :comments

      def initialize(redmine, json)
        @redmine = redmine
        @json = json
        @tracker = "Redmine"
        @id = @json["id"]
        @identifier = "##{@json["id"]}"
        @title = @json["subject"]
        @comments = []
        @json["journals"].each do |journal|
          next if journal["notes"].empty?
          @comments << Comment.new(journal)
        end
      end

      def sync_comments(comments)
        path = "issues/#{id}.json"
        comments.each do |comment|
          sync_comment(comment)
        end
      end

      def sync_comment(comment)
        my_comment = find_comment(comment)
        if my_comment
          my_comment.update(comment)
        else
          post_comment(comment)
        end
      end

      def find_comment(comment)
        @comments.each do |my_comment|
          return my_comment if my_comment.corresponding?(comment)
        end
        nil
      end

      def post_comment(comment)
        path = "issues/#{id}.json"
        params = {
          issue: {
            notes: comment.render
          }
        }
        @redmine.api_request(path, params, :put)
      end
    end

    class Comment < IssueComment
      attr_reader :tracker, :body, :created_at
      def initialize(json)
        @json = json
        @tracker = "Redmine"
        @body = @json["notes"]
        @created_at = Time.parse(@json["created_on"])
      end

      def update(comment)
        return if updated?(comment)
        # TODO: There is no API to update a comment
        # https://www.redmine.org/issues/10171
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
      response = http.request(req)
      if response.kind_of?(Net::HTTPSuccess)
        response
      else
        raise "#{uri}: #{response.code} #{response.message}"
      end
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
      Issue.new(self, issue_json)
    end

    def issues_by_custom_field(field_id, field_value, limit: nil)
      search_options = {
        "cf_#{field_id}".to_sym => field_value,
        :status_id => '*',
        :sort => 'id',
        :limit => limit,
      }
      issues(search_options)
    end

    def issue_by_custom_field(field_id, field_value)
      issues = issues_by_custom_field(field_id, field_value, limit: 1)
      issues.empty? ? nil : issues.first
    end
  end
end
