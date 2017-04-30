require 'grand_central/action'
require 'bowser/http'

require 'models/neighborhood'
require 'models/point_of_interest'

Action = GrandCentral::Action.create

GetCurrentLocation = Action.create
SetCurrentLocation = Action.with_attributes(:location)

FetchNeighborhoods = Action.create do
  def promise
    Bowser::HTTP.fetch '/api/neighborhoods'
  end
end

LoadNeighborhoods = Action.with_attributes(:json) do
  def neighborhoods
    json[:neighborhoods].map { |attrs| Neighborhood.new(attrs) }
  end
end

FetchPointsOfInterest = Action.create do
  def promise
    Bowser::HTTP.fetch '/api/points_of_interest'
  end
end

LoadPointsOfInterest = Action.with_attributes(:json) do
  def points_of_interest
    json[:points_of_interest].map do |attrs|
      PointOfInterest.new(attrs)
    end
  end
end

SelectNeighborhood = Action.with_attributes(:neighborhood_id)
SelectPOIType = Action.with_attributes(:type)
