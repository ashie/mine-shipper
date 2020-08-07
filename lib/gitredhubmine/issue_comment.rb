module GitRedHubMine
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
      updated_time >= comment.created_at
    end
  end
end
