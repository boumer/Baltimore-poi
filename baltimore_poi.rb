require 'roda'
require 'roda/opal_assets'
require 'opal'
require 'clearwater'
require 'grand_central'

require './config/database'
require './lib/monument'

class BaltimorePOI < Roda
  plugin :public
  plugin :json

  assets = Roda::OpalAssets.new

  route do |r|
    r.public
    assets.route r

    r.on 'api' do
      r.on 'neighborhoods' do
        {
          neighborhoods: Neighborhood.all.map { |neighborhood|
            {
              id: neighborhood.id,
              name: neighborhood.name,
            }
          },
        }
      end

      r.on 'points_of_interest' do
        poi = [Landmark, Library, Monument, Museum, Park, ReligiousBuilding].flat_map { |klass| klass.all.to_a }
        {
          points_of_interest: poi.map { |point|
            {
              id: point.uuid,
              name: point.name,
              coordinates: point.coordinates,
              type: point.class.name,
              neighborhood_id: point.neighborhood_id,
              image_url: point.image_urls,
              description: point.description,
            }
          },
        }
      end
    end

    <<-HTML
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="initial-scale=1.0">
    <meta charset="utf-8" />
    <title>Baltimore POI</title>
    <style>
      @keyframes fade-in {
        from { opacity: 0 }
        to   { opacity: 1 }
      }
    </style>
  </head>

  <body>
    <div id="app"></div>
    <script>
      window.gon = {
        icons: {

        },
      };
    </script>
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCw9xtudDTSAXj-XWba93DNETStZiD-81s" async defer></script>
    #{assets.js 'app.js'}
  </body>
</html>
    HTML
  end
end
