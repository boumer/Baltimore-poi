require 'roda'
require 'roda/opal_assets'
require 'opal'
require 'clearwater'
require 'grand_central'

require './config/database'

class BaltimorePOI < Roda
  plugin :public
  plugin :json

  assets = Roda::OpalAssets.new

  route do |r|
    r.public
    assets.route r

    <<-HTML
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="initial-scale=1.0">
    <meta charset="utf-8" />
    <title>Baltimore POI</title>
  </head>

  <body>
    <div id="app"></div>
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCw9xtudDTSAXj-XWba93DNETStZiD-81s"></script>
    #{assets.js 'app.js'}
  </body>
</html>
    HTML
  end
end
