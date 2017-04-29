require 'opal'
require 'clearwater'
require 'clearwater/black_box_node'

require 'store'
require 'actions'

class Layout
  include Clearwater::Component

  def render
    div([
      h1('Baltimore POI'),
      case current_location
      when nil
        p('Fetching location')
      else
        Google::Map.new(
          center: current_location,
          zoom: 13,
        )
      end,
    ])
  end

  def current_location
    if location = Store.state.user_location
      location
    elsif !@locating
      @locating = true
      GetCurrentLocation.call
      nil
    end
  end
end

module Google
  class Map
    include Clearwater::BlackBoxNode

    attr_reader :map

    def initialize(center:, zoom:)
      @center = LatLng.new(*center)
      @zoom = zoom
    end

    def node
      Clearwater::Component.div(
        style: {
          height: '600px',
        },
      )
    end

    def mount element
      @map = `new google.maps.Map({
        center: #{@center.to_n},
        zoom: #@zoom,
      })`
    end

    def update previous
      @map = previous.map

      `#@map.setCenter(#@center)`
    end
  end

  class LatLng
    attr_reader :lat, :lng

    def initialize lat, lng
      @lat = lat
      @lng = lng
    end

    def to_n
      `new google.maps.LatLng(#@lat, #@lng)`
    end
  end
end

router = Clearwater::Router.new do
end

app = Clearwater::Application.new(
  component: Layout.new,
  router: router,
  element: Bowser.document['#app'],
)
app.call

Store.on_dispatch { app.render }
