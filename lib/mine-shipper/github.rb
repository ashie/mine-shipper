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

require 'octokit'
require_relative './issue_comment.rb'

module MineShipper
  class GitHub
    def initialize(access_token = nil)
      @client = Octokit::Client.new(:access_token => access_token)
    end

    def issue(project_name, issue_id)
      @issue = @client.issue(project_name, issue_id)
      Issue.new(@client, project_name, issue_id)
    end

    class Issue
      attr_reader :comments

      def initialize(client, project_name, issue_id)
        @project_name = project_name
        @issue_id = issue_id
        @issue = client.issue(@project_name, @issue_id)
        @comments = [Comment.new(@issue)]
        comments = client.issue_comments(@project_name, @issue_id)
        comments.each do |comment|
          @comments << Comment.new(comment)
        end
      end

      def tracker
        "GitHub"
      end

      def identifier
        "#{@project_name}#{@issue_id}"
      end

      def title
        @issue.title
      end
    end

    class Comment < IssueComment
      attr_reader :tracker, :created_at, :updated_at, :url, :user, :body
      def initialize(comment)
        @comment = comment
        @tracker = "GitHub"
        @created_at = @comment.created_at
        @updated_at = @comment.updated_at
        @url = @comment.html_url
        @usr = @comment.user.login
        @body = @comment.body.gsub(/\R/, "\n")
      end
    end
  end
end
