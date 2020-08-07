require "test/unit"
require "test/unit/rr"
require "json"
require "time"
require_relative "../lib/gitredhubmine/redmine"

class TestRedmineIssue < Test::Unit::TestCase
  include GitRedHubMine

  TEST_ISSUE = {
    id: 13,
    subject: "test subject",
    journals: [
      {
        created_on: Time.parse("2020-08-06 09:41:42 +0000"),
        updated_on: Time.parse("2020-08-06 09:52:12 +0000"),
        notes: "hoge"
      },
      {
        created_on: Time.parse("2020-08-06 10:41:42 +0000"),
        updated_on: Time.parse("2020-08-06 10:52:12 +0000"),
        notes: ""
      },
      {
        created_on: Time.parse("2020-08-06 11:41:42 +0000"),
        updated_on: Time.parse("2020-08-06 11:52:12 +0000"),
        notes: "hage"
      }
    ]
  }

  setup do
    obj = JSON.parse(TEST_ISSUE.to_json)
    @issue = Redmine::Issue.new(nil, obj)
  end

  test "tracker" do
    assert_equal("Redmine", @issue.tracker)
  end

  test "id" do
    assert_equal(13, @issue.id)
  end

  test "identifier" do
    assert_equal("#13", @issue.identifier)
  end

  test "title" do
    assert_equal("test subject", @issue.title)
  end

  test "comments" do
    assert_equal(2, @issue.comments.length)
  end

  sub_test_case "post comments" do
    class TestComment < IssueComment
      attr_accessor :created_at, :updated_at, :user, :url, :body

      def initialize
        @created_at = Time.parse("2020-08-06 12:41:42 +0000")
        @updated_at = Time.parse("2020-08-06 12:52:12 +0000")
        @user = "foobar"
        @url = "https://example.com/issue/13#comment1"
        @body = "hoge"
      end
    end

    setup do
      @redmine = Redmine.new("https://redmine.example.com")
      obj = JSON.parse(TEST_ISSUE.to_json)
      @issue = Redmine::Issue.new(@redmine, obj)
      @comment = TestComment.new
      @comment_params = {
        issue: {
          notes: @comment.render
        }
      }
    end

    test "post_comment" do
      mock(@redmine).api_request("issues/13.json", @comment_params, :put) { "200" }
      assert_equal("200", @issue.post_comment(@comment))
    end

    test "sync_comment" do
      mock(@redmine).api_request("issues/13.json", @comment_params, :put) { "200" }
      assert_equal("200", @issue.sync_comment(@comment))
    end

    test "don't sync_comment" do
      stub(@issue.comments[0]).corresponding? {true}
      stub(@redmine).api_request do
        raise "Updating an issue isn't implemented yet since Redmine doesn't have API to do it"
      end
      assert_nil(@issue.sync_comment(@comment))
    end
  end
end

class TestRedmineComment < Test::Unit::TestCase
  include GitRedHubMine

  TEST_COMMENT = {
    created_on: Time.parse("2020-08-06 10:41:42 +0000"),
    updated_on: Time.parse("2020-08-06 10:52:12 +0000"),
    notes: "hoge"
  }

  setup do
    obj = JSON.parse(TEST_COMMENT.to_json)
    @comment = Redmine::Comment.new(obj)
  end

  test "tracker" do
    assert_equal("Redmine", @comment.tracker)
  end

  test "body" do
    assert_equal("hoge", @comment.body)
  end

  test "created_at" do
    assert_equal(TEST_COMMENT[:created_on], @comment.created_at)
  end

  test "updated_at" do
    assert_raise(NotImplemented) do
      assert_equal(TEST_COMMENT[:updated_on], @comment.updated_at)
    end
  end

  test "user" do
    assert_raise(NotImplemented) do
      assert_equal(TEST_COMMENT[:updated_on], @comment.user)
    end
  end
end
