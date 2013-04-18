# For post hook from github to irc

class GitServlet < BenderServlet
  # Provides a simple bridge of github url post hook data to IRC
  # http://localhost:9091/gitirc?room=github
  @mountpoint = "/gitirc" # required for Bender to know where to mount the servlet

  def do_GET(request, response)
    status = 200
    content_type = "text/html"
    body = "bender version #{BENDER_VERSION}"
    body += "\n"

    response.status = status
    response['Content-Type'] = content_type
    response.body = body
    response.body = body
  end

  def do_POST(request, response)
    status, content_type, body = post_to_irc(request)

    response.status = status
    response['Content-Type'] = content_type
    response.body = body
  end

  private

  def post_to_irc(request)
    bot_hash = {:rooms=>[], :payload=>nil, :token=>nil}
    request.query.collect do |key,value| 
      if key.match(/^room/)
        bot_hash[:rooms] << '#' + value
      end
      if key.match(/^payload/)
        bot_hash[:payload] = value
      end
      if key.match(/^token/)
        bot_hash[:token] = value
      end
    end
    unless Authenticated.git_call?(bot_hash[:token])
      Log.error "Git call has incorrect auth token. (#{bot_hash[:token]})"
      return 403, "text/plain", "not bad token"
    end
    rooms = bot_hash[:rooms] + BR_CONFIG['git']['rooms']
    rooms.uniq!

    if bot_hash[:payload]
      j = JSON.parse(bot_hash[:payload])
      repo = j['repository']['name']
      compare = j['compare']
      pusher = j['pusher']['name']
      owner = j['repository']['owner']['name']
      branch = j['ref']
      unless pusher == "name"
        rooms.each do |r|
          unless $bot.joined_rooms.include? r
            @bot.join_room r
          end
          @bot.say r, "[git-push] #{pusher} pushed to #{owner}/#{repo} [ref: #{branch}]"
          @bot.say r, "[git-push] #{compare}"
        end
      end
    end

    return 200, "text/plain", "accepted"
  end
end