require 'grand_central/model'

class PointOfInterest < GrandCentral::Model
  attributes(
    :id,
    :name,
    :coordinates,
    :type,
    :neighborhood_id,
    :image_url,
    :description,
  )
end
