#!/usr/bin/env ruby

$LOAD_PATH.unshift("./lib")

require 'gitredhubmine/config'
require 'gitredhubmine/github'
require 'gitredhubmine/redmine'

def dump_github_comment(comment)
  puts "========== GitHub Comment #{comment.created_at} =========="
  puts
  puts comment.render
  puts
end

config = GitRedHubMine::Config::new
project, issue = config[:github][:issue].split('#', 2)
github = GitRedHubMine::GitHub::new(config[:github][:access_token])
github_issue = github.issue(project, issue)

puts github_issue.title
puts
github_issue.comments.each do |comment|
  dump_github_comment(comment)
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
