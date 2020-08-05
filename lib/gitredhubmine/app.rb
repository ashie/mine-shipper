require_relative './config'
require_relative './github'
require_relative './redmine'

module GitRedHubMine
  class App
    def initialize
      @config = Config::new
    end

    def run
      @github_issue = github_issue
      puts @github_issue.title
      puts
      @github_issue.comments.each do |comment|
        dump_github_comment(comment)
      end

      @redmine_issue = redmine_issue
      @redmine_issue["journals"].each do |journal|
        next if journal["notes"].empty?
        dump_redmine_comment(journal)
      end
    end

    def github_issue
      project_name, issue_id = @config[:github][:issue].split('#', 2)
      github = GitHub::new(@config[:github][:access_token])
      github.issue(project_name, issue_id)
    end

    def redmine_issue
      redmine = Redmine.new(@config[:redmine][:base_url],
                            @config[:redmine][:custom_field_name],
                            @config[:redmine][:api_key])
      search_options = {
        "cf_#{redmine.custom_field_id}".to_sym => @config[:github][:issue],
        :status_id => '*',
        :sort => 'id',
        :limit => 1,
      }
      issues = redmine.issues(search_options)
      issue_id = issues.first["id"]
      redmine.issue(issue_id)
    end

    def dump_github_comment(comment)
      puts "========== GitHub Comment #{comment.created_at} =========="
      puts
      puts comment.render
      puts
    end

    def dump_redmine_comment(comment)
      puts "========== Redmine Comment #{comment["created_on"]} =========="
      puts
      puts comment["notes"]
      puts
    end
  end
end
