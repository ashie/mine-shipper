require "test/unit"
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
