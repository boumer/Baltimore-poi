require 'bundler/setup'
require './config/database'

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
    {
      Neighborhood => 'neighborhoods',
      Library => 'libraries',
      Monument => 'monuments',
    }.each do |klass, file|
      objects = CSV.read("#{file}.csv")
      objects.each { |obj| klass.create obj }
    end

    neighborhoods = Neighborhood.all.to_a
    Library.all.each do |library|
      neighborhood = neighborhoods.find { |n| n.name == library.neighborhood_name }
      neighborhood.libraries << library
    end
  end
end
