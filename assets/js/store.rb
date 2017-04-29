require 'grand_central'
require 'bowser/geolocation'

require 'actions'

class AppState < GrandCentral::Model
  attributes(
    :locations,
    :events,
    :user_location,
  )
end

initial_state = AppState.new(
  locations: [],
  events: [],
  user_location: nil,
)

Store = GrandCentral::Store.new(initial_state) do |state, action|
  case action
  when SetCurrentLocation
    state.update(
      user_location: [action.location.latitude, action.location.longitude],
    )
  else
    state
  end
end

Store.on_dispatch do |old, new, action|
  case action
  when GetCurrentLocation
    Bowser::Geolocation.locate
      .then(&SetCurrentLocation)
      .catch { |e| warn e }
  end
end

Action.store = Store
