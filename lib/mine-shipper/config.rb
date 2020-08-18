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

require 'optparse'
require 'dotenv/load'

module MineShipper
  class Config < Hash
    DEFAULT_CONFIG = {
      log_level: ENV["MINE_SHIPPER_LOG_LEVEL"] || 'WARN',
      github: {
        access_token: ENV["GITHUB_ACCESS_TOKEN"],
        issue: nil
      },
      redmine: {
        base_url: ENV["REDMINE_BASE_URL"],
        custom_field_name: ENV["REDMINE_CUSTOM_FIELD_NAME"],
        api_key: ENV["REDMINE_API_KEY"],
      }
    }

    def initialize(argv = ARGV)
      self.merge!(DEFAULT_CONFIG)
      OptionParser.new do |opts|
        opts.on("--github-issue ISSUE") do |github_issue|
          self[:github][:issue] = github_issue
        end
        opts.parse!(argv)
      end
    end
  end
end
