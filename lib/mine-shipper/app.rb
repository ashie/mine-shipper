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

    private

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
