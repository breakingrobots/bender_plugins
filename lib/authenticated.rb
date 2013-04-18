# A module for handling authenticating users

module Authenticated
  
  
  def Authenticated.user?(username)
    users = BR_CONFIG['auth']['users']
    if users.include? username
      return true
    end
    return false
  end
  
  def Authenticated.git_call?(token)
    if token.nil?
      return false
    end
    authed = BR_CONFIG['git']['token']
    if authed == token
      return true
    end
    return false
  end
  
end