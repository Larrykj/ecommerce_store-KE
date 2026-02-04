class ServerTimesController < ActionController::API
  def index
    render(
      json: {
        current: Time.current
      }
    )
  end
end
