#!/usr/bin/env ruby

$LOAD_PATH.unshift("./lib")

require 'optparse'
require 'octokit'
require 'dotenv/load'
require 'gitredhubmine/redmine'

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

redmine = GitRedHubMine::Redmine.new(ENV["REDMINE_BASE_URL"],
                                     ENV["REDMINE_CUSTOM_FIELD_NAME"],
                                     ENV["REDMINE_API_KEY"])
issues = redmine.get_issues(
  {
    "cf_#{redmine.custom_filed_id}": config[:github_project_issue],
    status_id: "*",
    sort: "id",
    limit: 1,
  })
issue_id = issues.first["id"]
redmine.get_issue(issue_id)["journals"].each do |journal|
  p journal
end
