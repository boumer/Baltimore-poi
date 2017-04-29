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
