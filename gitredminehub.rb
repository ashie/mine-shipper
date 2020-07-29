#!/usr/bin/env ruby

require 'optparse'
require 'net/https'
require 'uri'
require 'json'
require 'octokit'
require 'dotenv/load'

def parse_command_line_options(config)
  opts = OptionParser.new
  opts.on("--github-issue ISSUE") do |github_issue|
    project, issue = github_issue.split('#', 2)
    config[:github_project_issue] = github_issue
    config[:github_project] = project
    config[:github_issue] = issue
  end
  opts.parse!(ARGV)
  config
end

def render_comment(comment)
  title = "#{comment.user.login} commented on #{comment.created_at}"
  result  = "### [#{title}](#{comment.html_url})\n"
  result += "{{collapse(More...)\n"
  result += "* created_at: \"#{comment.created_at}\"\n"
  result += "* updated_at: \"#{comment.updated_at}\"\n"
  result += "}}\n"
  result += "\n"
  result += comment.body.gsub(/\R/, "\n")
  result
end

def dump_comment(comment)
  puts render_comment(comment)
  puts
  puts "#######################################################################################"
  puts
end

config = {}
parse_command_line_options(config)

client = Octokit::Client.new(:access_token => ENV["GITHUB_ACCESS_TOKEN"])
issue = client.issue(config[:github_project], config[:github_issue])
puts issue.title
puts
dump_comment(issue)

comments = client.issue_comments(config[:github_project], config[:github_issue])
comments.each do |comment|
  dump_comment(comment)
end


def redmine_api_request(path, params = {}, method = :get)
  url = "#{ENV["REDMINE_BASE_URL"]}/#{path}"
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
  req['X-Redmine-API-Key'] = ENV["REDMINE_API_KEY"]
  req.body = params.to_json

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.request(req)
end

def get_custom_fields(params = {})
  response = redmine_api_request("custom_fields.json", params)
  JSON.parse(response.body)["custom_fields"]
end

def get_issues(params = {})
  response = redmine_api_request("issues.json", params)
  JSON.parse(response.body)["issues"]
end

def get_issue(id)
  params = {
    include: "journals"
  }
  response = redmine_api_request("issues/#{id}.json", params)
  JSON.parse(response.body)["issue"]
end

def custom_filed_id
  fields = get_custom_fields
  field = fields.find do |field|
    field["name"] == ENV["REDMINE_CUSTOM_FIELD_NAME"]
  end
  field["id"]
end


issues = get_issues(
  {
    "cf_#{custom_filed_id}": config[:github_project_issue],
    status_id: "*",
    sort: "id",
    limit: 1,
  })
issue_id = issues.first["id"]
get_issue(issue_id)["journals"].each do |journal|
  p journal
end
