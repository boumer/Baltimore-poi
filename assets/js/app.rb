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
      h1({ style: Style.title }, 'Baltimore POI'),
      case current_location
      when nil
        div({ style: Style.getting_location }, [
          div('Getting location…'),
          div({ style: Style.copyright }, [
            'Copyright © 2017 Jamie Gaskins, Johann Liang, Andrei Koenig',
            div('Proudly made in Baltimore'),
          ]),
        ])
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
            zoom: 15,
            neighborhood_id: Store.state.selected_neighborhood_id,
            poi_type: Store.state.selected_poi_type,
          ),
          if selected_poi
            LightBox.new(selected_poi)
          end,
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

  def selected_poi
    Store.state.selected_poi
  end

  module Style
    module_function

    def getting_location
      {
        font_size: '30px',
        font_family: 'sans-serif',
        text_align: :center,
        margin_top: '30vh',
      }
    end

    def title
      {
        font_family: 'sans-serif',
        font_weight: :bold,
      }
    end

    def copyright
      {
        position: :absolute,
        font_size: '16px',
        color: '#aaa',
        bottom: '10px',
      }
    end
  end
end

module Google
  class Map
    include Clearwater::BlackBoxNode

    attr_reader :map, :poi, :neighborhood_id

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
          maxZoom: 15,
        }
      )`
      @poi = Store.state.points_of_interest.map { |poi|
        lat_lng = LatLng.new(*poi.coordinates)
        POI.new(poi, `new google.maps.Marker({
          position: #{lat_lng},
          visible: true,
          map: #@map,
        })`) do |point|
          puts 'click handler!'
          @poi.each(&:close_info)
          point.open_info
        end
      }
    end

    def update previous
      @map = previous.map
      @poi = previous.poi

      @poi.each do |poi|
        poi.visible = visible?(poi)
      end

      if neighborhood_id != previous.neighborhood_id
        bounds = @poi
          .select(&:visible?)
          .each_with_object(`new google.maps.LatLngBounds()`) { |point, bounds|
            `bounds.extend(#{LatLng.new(*point.coordinates).to_n})`
          }

        `#@map.fitBounds(#{bounds})`
      end
    end

    def visible? poi
      (@poi_type.nil? || @poi_type == 'null' || poi.type == @poi_type) &&
      (@neighborhood_id.nil? || @neighborhood_id == 'null' || poi.neighborhood_id == @neighborhood_id)
    end

    class POI
      def initialize poi, marker, &click_handler
        @poi = poi
        @marker = marker
        `marker.addListener('click', #{proc { SelectPOI.call(poi) }})`
      end

      def coordinates
        @poi.coordinates
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

      def visible?
        `#@marker.getVisible()`
      end

      def open_info
        content = %{<h1>#{@poi.name}</h1><div style='text-align: center; overflow-y: scroll'><img src="#{@poi.image_url}" /></div><p>#{@poi.description}</p>}
        %x{
          #@info = new google.maps.InfoWindow({ content: #{content} });
          #@info.open(#@marker.getMap(), #@marker);
        }
      end

      def close_info
        @info && `#@info.close()`
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

class LightBox
  include Clearwater::Component

  def initialize point
    @point = point
  end

  def render
    div({ style: Style.overlay }, [
      div({ style: Style.container }, [
        button({ style: Style.close_button, onclick: SelectPOI[nil] }, 'x'),
        h1({ style: Style.title }, @point.name),
        div({ style: Style.image_container }, img(src: @point.image_url)),
        p(@point.description),
      ]),
    ])
  end

  module Style
    module_function

    def overlay
      {
        position: :absolute,
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        margin: 0,
        padding: 0,
        background: 'rgba(0,0,0, 0.5)',
        animation: 'fade-in 500ms',
      }
    end

    def title
      {
        font_family: 'sans-serif',
        font_size: '20px',
        margin_top: 0,
      }
    end

    def image_container
      {
        text_align: :center,
      }
    end

    def container
      {
        background: :white,
        color: :black,
        margin: '10vh auto',
        padding: '30px 1em 1em',
        overflow_y: :scroll,
        position: :relative,
        width: '80%',
        max_width: '500px',
        max_height: '80vh',
      }
    end

    def close_button
      {
        position: :absolute,
        right: '10px',
        top: '10px',
        background: :white,
        color: '#888',
      }
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
