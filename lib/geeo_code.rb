require 'yajl'
require 'open-uri'
require 'cgi'

require 'geeo_code/version'
# GeeoCode is a super simple reverse geocoding wrapper for the Google geocoding apis.
# 
# Currently it only supports the JSON encoding, but this will probably change in the future
# in case, for whatever reason, people would rather have it fetched via XML. It really shouln't
# make any difference since all you get back is a hash of the values.
#
# There is only one method you really need to worry about is reverse. This simply takes an address
# and returns the reverse geocoded data.
#
# Simple example:
#
#     coder = Geeocode.new
#     coder.reverse("6 Woodward Ave, Hilton Head Island, SC")
#
# Will return the geocode info for the given address.
#
class GeeoCode
  GOOGLE_ENDPOINT = "http://maps.googleapis.com/maps/api/geocode/".freeze

  VALID_OPTIONS = [:proxy, :sensor, :format]

  attr_accessor *VALID_OPTIONS

  # Valid options are 
  #     :proxy => true|false
  #     :sensor => true|false
  #     :format => "json"|"xml"
  #
  # The proxy lets you ignore any environmental `http_proxy` settings.
  # The sensor alerts google to whether or not this is a gps enabled device.
  # The format specifies whether or not we want the results to be parsed from JSON or XML.
  #
  def initialize( args={} )
    options =  {:proxy => false, :sensor => false, :format => 'json' }
    options.merge! args
    options.map {|k,v| send("#{k}=".to_sym, v)}
  end

  # Takes an address, returns a hash with the following:
  #
  #   :address => The address info
  #   :geometry => Geometry info (lat/long, etc.)
  #   :match_type => "Exact or partial match.
  #
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

  def print
    url = URI.parse("#{GOOGLE_ENDPOINT}#{format}?address=#{CGI::escape(address)}&sensor=#{sensor}")
    puts url
    return url
  end
end
