require 'octokit'

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

    class Comment
      def initialize(comment)
        @comment = comment
      end

      def created_at
        @comment.created_at
      end

      def render
        title = "#{@comment.user.login} commented on #{@comment.created_at}"
        result  = "### [#{title}](#{@comment.html_url})\n"
        result += "{{collapse(More...)\n"
        result += "* created_at: \"#{@comment.created_at}\"\n"
        result += "* updated_at: \"#{@comment.updated_at}\"\n"
        result += "}}\n"
        result += "\n"
        result += @comment.body.gsub(/\R/, "\n")
        result
      end
    end
  end
end
