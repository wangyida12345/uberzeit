Warden::Manager.serialize_into_session { |user| user.id }
Warden::Manager.serialize_from_session { |id| User.find(id) }

Warden::Strategies.add(:token) do
  def valid?
    !env['HTTP_X_AUTH_TOKEN'].blank?
  end

  def authenticate!
    u = User.find_by_authentication_token(env['HTTP_X_AUTH_TOKEN'])
    u.nil? ? fail!("Could not log in") : success!(u)
  end
end

Warden::Strategies.add(:session) do
  def valid?
    !env['rack.session']['user_id'].blank?
  end

  def authenticate!
    u = User.find(env['rack.session']['user_id'])
    u.nil? ? fail!("Could not log in") : success!(u)
  end
end
