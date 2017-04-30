require './config/database'

class Neighborhood
  include Neo4j::ActiveNode

  property :name, type: String

  has_many :in, :monuments, type: :IN_NEIGHBORHOOD, model_class: :Monument
  has_many :in, :libraries, type: :IN_NEIGHBORHOOD, model_class: :Library
  has_many :in, :museums, type: :IN_NEIGHBORHOOD, model_class: :Museum
  has_many :in, :parks, type: :IN_NEIGHBORHOOD, model_class: :Park
  has_many :in, :religious_buildings, type: :IN_NEIGHBORHOOD, model_class: :ReligiousBuilding
  has_many :in, :landmarks, type: :IN_NEIGHBORHOOD, model_class: :Landmark
end

class Monument
  include Neo4j::ActiveNode

  property :name, type: String
  property :coordinates
  property :address, type: String
  property :image_urls, type: String
  property :description, type: String

  has_one :out, :neighborhood, type: :IN_NEIGHBORHOOD, model_class: :Neighborhood
end

class Library
  include Neo4j::ActiveNode

  property :name, type: String
  property :coordinates
  property :address, type: String
  property :image_urls, type: String
  property :description, type: String


  has_one :out, :neighborhood, type: :IN_NEIGHBORHOOD, model_class: :Neighborhood
end

class Museum
  include Neo4j::ActiveNode

  property :name, type: String
  property :coordinates
  property :address, type: String
  property :image_urls, type: String
  property :description, type: String

  has_one :out, :neighborhood, type: :IN_NEIGHBORHOOD, model_class: :Neighborhood
end

class Park
  include Neo4j::ActiveNode

  property :name, type: String
  property :coordinates
  property :address, type: String
  property :image_urls, type: String
  property :description, type: String

  has_one :out, :neighborhood, type: :IN_NEIGHBORHOOD, model_class: :Neighborhood
end

class Landmark
  include Neo4j::ActiveNode

  property :name, type: String
  property :coordinates
  property :address, type: String
  property :image_urls, type: String
  property :description, type: String

  has_one :out, :neighborhood, type: :IN_NEIGHBORHOOD, model_class: :Neighborhood
end

class ReligiousBuilding
  include Neo4j::ActiveNode

  property :name, type: String
  property :coordinates
  property :address, type: String
  property :image_urls, type: String
  property :description, type: String

  has_one :out, :neighborhood, type: :IN_NEIGHBORHOOD, model_class: :Neighborhood
end
