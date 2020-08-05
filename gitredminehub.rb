#!/usr/bin/env ruby

$LOAD_PATH.unshift("./lib")

require 'optparse'
require 'octokit'
require 'dotenv/load'
require 'gitredhubmine/redmine'

def parse_command_line_options(config)
  opts = OptionParser.new
  opts.on("--github-issue ISSUE") do |github_issue|
    config[:github][:issue] = github_issue
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
  puts "========== GitHub Comment #{comment["created_at"]} =========="
  puts
  puts render_comment(comment)
  puts
end

config = {
  github: {
    access_token: ENV["GITHUB_ACCESS_TOKEN"],
    issue: nil
  },
  redmine: {
    base_url: ENV["REDMINE_BASE_URL"],
    custom_filed_name: ENV["REDMINE_CUSTOM_FIELD_NAME"],
    api_key: ENV["REDMINE_API_KEY"],
  }
}
parse_command_line_options(config)

project, issue_id = config[:github][:issue].split('#', 2)
client = Octokit::Client.new(:access_token => config[:github][:access_token])
issue = client.issue(project, issue_id)
puts issue.title
puts
dump_comment(issue)

comments = client.issue_comments(project, issue_id)
comments.each do |comment|
  dump_comment(comment)
end

redmine = GitRedHubMine::Redmine.new(config[:redmine][:base_url],
                                     config[:redmine][:custom_filed_name],
                                     config[:redmine][:api_key])
search_options = {
  "cf_#{redmine.custom_filed_id}".to_sym => config[:github][:issue],
  :status_id => '*',
  :sort => 'id',
  :limit => 1,
}
issues = redmine.issues(search_options)
issue_id = issues.first["id"]
redmine.issue(issue_id)["journals"].each do |journal|
  next if journal["notes"].empty?
  puts "========== Redmine Comment #{journal["created_on"]} =========="
  puts
  puts journal["notes"]
  puts
end
