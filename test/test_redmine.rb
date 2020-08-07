require "test/unit"
require "json"
require_relative "../lib/gitredhubmine/redmine"

class TestRedmineComment < Test::Unit::TestCase
  include GitRedHubMine

  test "body" do
    json = { notes: "hoge" }.to_json
    a = Redmine::Comment.new(JSON.parse(json))
    assert_equal("hoge", a.body)
  end
end
