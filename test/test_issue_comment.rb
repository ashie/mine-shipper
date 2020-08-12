require "test/unit"
require "json"
require "time"
require_relative "../lib/mine-shipper/issue_comment"

class TestIssueComment < Test::Unit::TestCase
  include MineShipper

  CREATED_TIME = Time.parse("2020-08-06 10:41:42 +0000")
  UPDATED_TIME = Time.parse("2020-08-06 10:52:12 +0000")
  EXPECTED_FIRST_LINE = "### [foobar commented on #{CREATED_TIME.getlocal}](http://example.com/issue/1234)\n"
  EXPECTED_BODY =
    EXPECTED_FIRST_LINE +
    "{{collapse(More...)\n" +
    "* created_at: \"#{CREATED_TIME.getlocal}\"\n" +
    "* updated_at: \"#{UPDATED_TIME.getlocal}\"\n"+
    "}}\n" +
    "\n" +
    "hoge"

  class TestComment < IssueComment
    attr_reader :created_at, :user, :url, :body
    attr_accessor :body, :updated_at

    def initialize
      @created_at = CREATED_TIME
      @updated_at = UPDATED_TIME
      @user = "foobar"
      @url = "http://example.com/issue/1234"
      @body = "hoge"
    end
  end

  test "render" do
    comment = TestComment.new
    assert_equal(EXPECTED_BODY, comment.render)
  end

  data('corresponding' => [EXPECTED_FIRST_LINE, true],
       'with heading space' => [" " + EXPECTED_FIRST_LINE, false],
       'missing line break' => [EXPECTED_FIRST_LINE.delete("\n"), false],
       'different user' => [EXPECTED_FIRST_LINE.gsub("foobar", "hoge"), false],
       'different date' => [EXPECTED_FIRST_LINE.gsub("2020", "2018"), false],
       'different url' => [EXPECTED_FIRST_LINE.gsub("example.com", "example.org"), false])
  test "corresponding?" do |data|
    body, expected = data
    comment1 = TestComment.new
    comment2 = TestComment.new
    comment1.body = body
    assert_equal(expected, comment1.corresponding?(comment2))
  end

  data('same date'           => ["2020-08-06 10:52:12 +0000", true],
       'updated at upstream' => ["2020-08-06 10:52:13 +0000", false],
       'past date'           => ["2020-08-06 10:52:11 +0000", true])
  test "updated?" do
    date, expected = data
    comment1 = TestComment.new
    comment2 = TestComment.new
    comment1.body = EXPECTED_BODY
    comment2.updated_at = Time.parse(date)
    assert_equal(expected, comment1.updated?(comment2))
  end
end
