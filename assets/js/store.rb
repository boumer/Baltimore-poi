require 'grand_central'
require 'bowser/geolocation'

require 'actions'

class AppState < GrandCentral::Model
  attributes(
    :neighborhoods,
    :user_location,
    :points_of_interest,
    :selected_neighborhood_id,
    :selected_poi_type,
  )
end

initial_state = AppState.new(
  neighborhoods: [],
  points_of_interest: [],
  user_location: nil,
  # icon_set: IconSet.new(`gon.icons`),
)

Store = GrandCentral::Store.new(initial_state) do |state, action|
  case action
  when SetCurrentLocation
    state.update(
      user_location: [action.location.latitude, action.location.longitude],
    )
  when LoadNeighborhoods
    state.update(
      neighborhoods: action.neighborhoods.sort_by(&:name),
    )
  when LoadPointsOfInterest
    state.update(
      points_of_interest: action.points_of_interest,
    )
  when SelectNeighborhood
    state.update(selected_neighborhood_id: action.neighborhood_id)
  when SelectPOIType
    state.update(selected_poi_type: action.type)
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
  when FetchNeighborhoods
    action.promise
      .then(&:json)
      .then(&LoadNeighborhoods)
      .catch { |e| warn e }
  when FetchPointsOfInterest
    action.promise
      .then(&:json)
      .then(&LoadPointsOfInterest)
      .catch { |e| warn e }
  end
end

Action.store = Store
