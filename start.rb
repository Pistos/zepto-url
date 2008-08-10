require 'ramaze'

class MainController < Ramaze::Controller
  MAP_DIR = "mapping"
  # If you change ID_CHARS ensure that it's filesystem safe.
  ID_CHARS = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
  ZEPTO_URI_BASE = "http://zep.purepistos.net/pez/"
  
  def index
  end
  
  def zep( uri = nil )
    uri ||= request[ 'uri' ]
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
  
  def pez( id )
    if id
      id.gsub!( /[^#{ID_CHARS}]/, '' )
      uri = File.read( zepto_path( id ) ).strip
      if not uri.empty?
        redirect uri
      end
    end
    redirect '/'
  end
  
  def zepto_path( id )
    "#{MAP_DIR}/#{id}"
  end
  private :zepto_path
end

Ramaze.start :adapter => :mongrel, :port => 8006
