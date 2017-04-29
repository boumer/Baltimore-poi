require './config/database'

class Neighborhood
  include Neo4j::ActiveNode

  property :name, type: String

  has_many :in, :monuments, type: :IN_NEIGHBORHOOD, model_class: :Monument
  has_many :in, :libraries, type: :IN_NEIGHBORHOOD, model_class: :Library
end

class Monument
  include Neo4j::ActiveNode

  property :name, type: String
  property :location
  property :address, type: String

  has_one :out, :neighborhood, type: :IN_NEIGHBORHOOD, model_class: :Neighborhood
end

class Library
  include Neo4j::ActiveNode

  property :name, type: String
  property :location
  property :address, type: String

  has_one :out, :neighborhood, type: :IN_NEIGHBORHOOD, model_class: :Neighborhood
end
