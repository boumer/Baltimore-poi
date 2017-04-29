require 'bundler/setup'
require './config/database'
require './lib/monument.rb'
require 'pry'
require 'csv'

load 'neo4j/tasks/migration.rake'

namespace :assets do
  # Keep a single asset compiler in case we want to use it for multiple tasks.
  require 'opal'
  require 'clearwater'
  require 'roda/opal_assets'
  assets = Roda::OpalAssets.new(env: :production)

  desc 'Precompile assets for production'
  task :precompile do
    assets << 'app.js'
    assets.build
  end
end

namespace :db do
  desc 'Seed the database'
  task :seed do
    Neighborhood.delete_all
    neighborhoods = []
    {
      Library => 'libraries',
      Monument => 'monuments',
      Museum => 'museums',
      Park => 'parks',
      ReligiousBuilding => 'religious_buildings',
      Landmark => 'landmarks'
    }.each do |klass, file|
      puts "Seeding #{klass}"
      klass.delete_all
      CSV.foreach("data/#{file}.csv", headers: true) do |row|
        hash = row.to_hash
        hash.each do |k,v|
          if v.nil?
            next
          end
          v.gsub!("\n", " ")
        end
        if hash.key?("Location 1")
          hash["address"] = hash.delete("Location 1")
        end
        if klass == Park
          hash["neighborhood"] = hash.delete("district")
        end
        hash["neighborhood"] = Neighborhood.find_or_create_by(name: hash.fetch("neighborhood"))
        klass.create hash
      end
    end
  end
end
