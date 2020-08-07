require "test/unit"
require "json"
require "time"
require_relative "../lib/gitredhubmine/issue_comment"

class TestIssueComment < Test::Unit::TestCase
  include GitRedHubMine

  class TestComment < IssueComment
    attr_reader :created_at, :updated_at, :user, :url, :body
    attr_accessor :body

    def initialize
      @created_at = Time.parse("2020-08-06 10:41:42 +0000")
      @updated_at = Time.parse("2020-08-06 10:52:12 +0000")
      @user = "foobar"
      @url = "http://example.com/issue/1234"
      @body = "hoge"
    end
  end

  test "render" do
    comment = TestComment.new
    expected = 
      "### [foobar commented on #{comment.created_at.getlocal}](http://example.com/issue/1234)\n" +
      "{{collapse(More...)\n" +
      "* created_at: \"#{comment.created_at.getlocal}\"\n" +
      "* updated_at: \"#{comment.updated_at.getlocal}\"\n"+
      "}}\n" +
      "\n" +
      "hoge"
    assert_equal(expected, comment.render)
  end

  test "corresponding?" do
    comment1 = TestComment.new
    comment2 = TestComment.new
    comment1.body = "### [foobar commented on #{comment1.created_at.getlocal}](http://example.com/issue/1234)\n"
    assert_true(comment1.corresponding?(comment2))
  end
end
