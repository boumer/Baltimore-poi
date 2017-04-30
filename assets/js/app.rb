require 'opal'
require 'clearwater'
require 'clearwater/black_box_node'

require 'store'
require 'actions'

class Layout
  include Clearwater::Component

  def initialize
    FetchNeighborhoods.call
    FetchPointsOfInterest.call
  end

  def render
    div([
      h1('Baltimore POI'),
      case current_location
      when nil
        p('Fetching location')
      else
        div([
          select({ onchange: SelectNeighborhood }, [
            option({ value: nil }, 'Select Neighborhood'),
            neighborhoods.map { |n|
              option({ value: n.id }, n.name)
            },
          ]),
          select({ onchange: SelectPOIType }, [
            option({ value: nil }, 'Select POI Type'),
            %w(Landmark Library Monument Museum Park Religious_Building).map { |type|
              option({ value: type.gsub('_', '') }, type.gsub('_', ' '))
            },
          ]),
          Google::Map.new(
            center: current_location,
            zoom: 14,
            neighborhood_id: Store.state.selected_neighborhood_id,
            poi_type: Store.state.selected_poi_type,
          ),
        ])
      end,
    ])
  end

  def neighborhoods
    Store.state.neighborhoods
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

    attr_reader :map, :poi

    def initialize(center:, zoom:, neighborhood_id:, poi_type: nil)
      @center = LatLng.new(*center)
      @zoom = zoom
      @neighborhood_id = neighborhood_id
      @poi_type = poi_type
    end

    def node
      Clearwater::Component.div(
        style: {
          height: '75vh',
        },
      )
    end

    def mount element
      @map = `new google.maps.Map(
        #{element.to_n},
        {
          center: #{@center.to_n},
          zoom: #@zoom,
          disableDefaultUI: true,
        }
      )`
      @poi = Store.state.points_of_interest.map { |poi|
        POI.new(poi, `new google.maps.Marker({
          position: #{LatLng.new(*poi.coordinates)},
          visible: true,
          map: #@map,
        })`)
      }
    end

    def update previous
      @map = previous.map
      @poi = previous.poi

      `#@map.setCenter(#@center)`

      @poi.each do |poi|
        poi.visible = visible?(poi)
      end
    end

    def visible? poi
      (@poi_type.nil? || @poi_type == 'null' || poi.type == @poi_type) &&
      (@neighborhood_id.nil? || @neighborhood_id == 'null' || poi.neighborhood_id == @neighborhood_id)
    end

    class POI
      def initialize poi, marker
        @poi = poi
        @marker = marker
      end

      def neighborhood_id
        @poi.neighborhood_id
      end

      def type
        @poi.type
      end

      def visible= value
        `#@marker.setVisible(!!value)`
      end
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
