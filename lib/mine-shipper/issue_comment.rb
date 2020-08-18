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

module MineShipper
  class NotImplemented < StandardError
  end

  class IssueComment
    def tracker
      "Unknown"
    end

    def created_at
      raise NotImplemented
    end

    def updated_at
      raise NotImplemented
    end

    def url
      raise NotImplemented
    end

    def user
      raise NotImplemented
    end

    def body
      raise NotImplemented
    end

    def render
      title = "#{user} commented on #{created_at.getlocal}"
      result  = "### [#{title}](#{url})\n"
      result += "{{collapse(More...)\n"
      result += "* created_at: \"#{created_at.getlocal}\"\n"
      result += "* updated_at: \"#{updated_at.getlocal}\"\n"
      result += "}}\n"
      result += "\n"
      result += body
      result
    end

    def corresponding?(comment)
      escaped_url = Regexp.escape(comment.url)
      escaped_time = Regexp.escape("#{comment.created_at.getlocal}")
      if body.match(/^### \[#{comment.user} commented on #{escaped_time}\]\(#{escaped_url}\)\n/)
        true
      else
        false
      end
    end

    def updated?(comment)
      lines = body.split("\n", 6)
      return false if lines[1] != "{{collapse(More...)"
      return false if lines[4] != "}}"
      timestr = lines[3].match(/^\* updated_at: \"(.*)\"$/).to_a[1]
      return false if timestr.nil?
      updated_time = Time.parse(timestr)
      updated_time >= comment.updated_at
    end
  end
end
