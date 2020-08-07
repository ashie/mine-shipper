require "test/unit"
require "json"
require "time"
require_relative "../lib/gitredhubmine/issue_comment"

class TestIssueComment < Test::Unit::TestCase
  include GitRedHubMine

  CREATED_TIME = Time.parse("2020-08-06 10:41:42 +0000")
  UPDATED_TIME = Time.parse("2020-08-06 10:52:12 +0000")
  EXPECTED_FIRST_LINE = "### [foobar commented on #{CREATED_TIME.getlocal}](http://example.com/issue/1234)\n"

  class TestComment < IssueComment
    attr_reader :created_at, :updated_at, :user, :url, :body
    attr_accessor :body

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
    expected = 
      EXPECTED_FIRST_LINE +
      "{{collapse(More...)\n" +
      "* created_at: \"#{CREATED_TIME.getlocal}\"\n" +
      "* updated_at: \"#{UPDATED_TIME.getlocal}\"\n"+
      "}}\n" +
      "\n" +
      "hoge"
    assert_equal(expected, comment.render)
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
end
