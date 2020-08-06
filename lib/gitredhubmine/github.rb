require 'octokit'
require_relative './issue_comment.rb'

module GitRedHubMine
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
        @issue = client.issue(project_name, issue_id)
        @comments = [Comment.new(@issue)]
        comments = client.issue_comments(project_name, issue_id)
        comments.each do |comment|
          @comments << Comment.new(comment)
        end
      end

      def title
        @issue.title
      end
    end

    class Comment < IssueComment
      def initialize(comment)
        @comment = comment
      end

      def created_at
        @comment.created_at
      end

      def updated_at
        @comment.updated_at
      end

      def url
        @comment.html_url
      end

      def user
        @comment.user.login
      end

      def body
        @comment.body.gsub(/\R/, "\n")
      end
    end
  end
end
