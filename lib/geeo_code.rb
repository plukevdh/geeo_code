require 'yajl'
require 'open-uri'
require 'cgi'

require 'geeo_code/version'

class GeeoCode
  GOOGLE_ENDPOINT = "http://maps.googleapis.com/maps/api/geocode/".freeze

  VALID_OPTIONS = [:proxy, :sensor, :format]

  attr_accessor *VALID_OPTIONS

  def initialize( options={} )
    options.map {|k,v| send("#{k}=".to_sym, v)}
  end

  def configure
    yield self    
  end
  
  def reverse(address)
    begin  
      url = URI.parse("#{GOOGLE_ENDPOINT}#{format}?address=#{CGI::escape(address)}&sensor=#{sensor}")
      content = open(url, :proxy => proxy)
      doc = Yajl::Parser.parse(content, :symbolize_keys => true)

      address = {}
      geometry = {}
      match_type = "none"
      # puts doc

      if doc[:status] == "OK"
        results = doc[:results].first

        data = results[:address_components]
        data.each do |piece|
          address[:street_number] = piece[:short_name] if piece[:types].include? "street_number"
          address[:street_name] = piece[:short_name] if piece[:types].include? "route"
          address[:city] = piece[:short_name] if piece[:types].include? "locality"
          address[:state] = piece[:short_name] if piece[:types].include? "administrative_area_level_1"
          address[:zip_code] = piece[:short_name] if piece[:types].include? "postal_code"
        end

        geometry = results[:geometry]
        lat_lang = results[:geometry][:location]
        match_type = results[:partial_match] ? "partial" : "exact"

      end

      return {:address => address, :geometry => geometry, :match_type => match_type}
    rescue Object => err
      msg = "Error! #{err.message}"
      puts msg 
    end
  end
end
