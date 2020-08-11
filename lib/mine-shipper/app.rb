require 'logger'
require_relative './config'
require_relative './github'
require_relative './redmine'

module MineShipper
  class App
    def initialize
      @config = Config::new
      @issue_key = @config[:github][:issue]
      @logger = Logger.new(STDOUT)
      @logger.level = @config[:log_level]
    end

    def run
      begin
        do_run
      rescue Exception => e
        @logger.error(e)
      end
    end

    def do_run
      @logger.info("Fetching #{@issue_key} comments on Redmine...")
      redmine_issue = get_redmine_issue
      if redmine_issue
        @logger.info("Fetching #{@issue_key} comments on GitHub...")
        github_issue = get_github_issue
        dump_issue(github_issue)
        dump_issue(redmine_issue)
        redmine_issue.sync_comments(github_issue.comments)
        @logger.info("Done synchronizing issue comments of #{@issue_key}")
      else
        @logger.info("Cannot find Redmine issue for #{@issue_key}")
      end
    end

    def get_github_issue
      project_name, issue_id = @issue_key.split('#', 2)
      github = GitHub::new(@config[:github][:access_token])
      github.issue(project_name, issue_id)
    end

    def get_redmine_issue
      redmine = Redmine.new(@config[:redmine][:base_url],
                            @config[:redmine][:api_key])
      redmine.issue_by_custom_field(@config[:redmine][:custom_field_name],
                                    @issue_key)
    end

    def dump_issue(issue)
      @logger.debug("#{issue.tracker} Issue \##{issue.identifier}: #{issue.title}")
      issue.comments.each do |comment|
        dump_comment(comment)
      end
    end

    def dump_comment(comment)
      time = comment.created_at.getlocal
      @logger.debug("#{comment.tracker} Comment #{time}\n#{comment.body}")
    end
  end
end
