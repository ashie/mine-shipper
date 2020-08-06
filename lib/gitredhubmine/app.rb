require 'logger'
require_relative './config'
require_relative './github'
require_relative './redmine'

module GitRedHubMine
  class App
    def initialize
      @config = Config::new
      @logger = Logger.new(STDOUT)
      @logger.level = @config[:log_level]
    end

    def run
      @github_issue = get_github_issue
      @redmine_issue = get_redmine_issue
      debug_dump
    end

    def get_github_issue
      project_name, issue_id = @config[:github][:issue].split('#', 2)
      github = GitHub::new(@config[:github][:access_token])
      github.issue(project_name, issue_id)
    end

    def get_redmine_issue
      redmine = Redmine.new(@config[:redmine][:base_url],
                            @config[:redmine][:api_key])
      issues = redmine.issues_by_custom_field(@config[:redmine][:custom_field_name],
                                              @config[:github][:issue])
      issues.first
    end

    def debug_dump
      @logger.debug("GitHub issue #{@config[:github][:issue]}: #{@github_issue.title}")
      @github_issue.comments.each do |comment|
        dump_github_comment(comment)
      end

      @redmine_issue.comments.each do |comment|
        next if comment.body.empty?
        dump_redmine_comment(comment)
      end
    end

    def dump_github_comment(comment)
      log  = "========== GitHub Comment #{comment.created_at} ==========\n\n"
      log += "#{comment.render}\n"
      @logger.debug(log)
    end

    def dump_redmine_comment(comment)
      log  = "========== Redmine Comment #{comment.created_at} ==========\n"
      log += "#{comment.body}\n"
      @logger.debug(log)
    end
  end
end
