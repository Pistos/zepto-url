require 'ramaze'

class MainController < Ramaze::Controller
  MAP_DIR = "mapping"
  # If you change ID_CHARS ensure that it's filesystem safe.
  ID_CHARS = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
  ZEPTO_URI_BASE = "http://zep.purepistos.net/"
  
  def index( id = nil )
    if id
      id.gsub!( /[^#{ID_CHARS}]/, '' )
      path = zepto_path( id )
      if File.exists?( path ) and File.file?( path )
        uri = File.read( path ).strip
        if not uri.empty?
          redirect uri
        end
      end
    end
  end
  
  def zep( uri = nil, zepto_uri_only = nil )
    uri ||= request[ 'uri' ]
    @zepto_uri_only = zepto_uri_only || request[ 'zepto_uri_only' ]
    if not File.exist?( MAP_DIR )
      FileUtils.mkdir MAP_DIR
    end
    
    path = nil
    loop do
      zepto_id = ""
      8.times do
        zepto_id << ID_CHARS[ rand( ID_CHARS.size - 1 ) ]
      end
      @zepto_uri = "#{ZEPTO_URI_BASE}#{zepto_id}"
      path = zepto_path( zepto_id )
      
      break if not File.exist?( path )
    end
    
    File.open( path, 'w' ) do |f|
      f.puts uri
    end
    
    @original_uri = uri
  end
  
  def error
    "Huh? 404! Or is that 500? <a href='/'>Home</a>"
  end
  
  def zepto_path( id )
    "#{MAP_DIR}/#{id}"
  end
  private :zepto_path
end

Ramaze.start :adapter => :mongrel, :port => 8006
