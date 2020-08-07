require "test/unit"
require "json"
require "time"
require_relative "../lib/gitredhubmine/redmine"

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
