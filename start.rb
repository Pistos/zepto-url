require 'ramaze'

# By Pistos
# http://blog.purepistos.net
# Clever id generation algorithm by manveru.


class MainController < Ramaze::Controller
  MAP_DIR = "mapping"
  # If you change ID_CHARS ensure that it's filesystem safe.
  ID_CHARS = (48..128).map{ |c| c.chr }.grep( /[[:alnum:]]/ )
  ZEPTO_URI_BASE = "http://zep.purepistos.net/"
  
  def initialize
    if not File.exist?( MAP_DIR )
      FileUtils.mkdir MAP_DIR
    end
  end
  
  # Redirect using zepto id, or show home page.
  def index( id = nil )
    if id
      id.gsub!( /[^#{ID_CHARS}]/, '' )
      id.gsub!( %r{[./]}, '' )
      path = zepto_path( id )
      if File.exists?( path ) and File.file?( path )
        uri = File.read( path ).strip
        if not uri.empty?
          redirect uri
        end
      end
    end
  end
  
  # Zep up a URI and show a result page.
  def zep( zepto_uri_only = nil )
    uri = request[ 'uri' ]
    @zepto_uri_only = zepto_uri_only || request[ 'zepto_uri_only' ]
    
    # Generate unique ID for the URI.
    i = Dir[ "#{MAP_DIR }/*" ].size
    r = 0
    a = []
    while i > 0
      i, r = i.divmod ID_CHARS.size
      a.unshift r
    end
    zepto_id = a.map { |c| ID_CHARS[ c ] }.join
    
    @zepto_uri = "#{ZEPTO_URI_BASE}#{zepto_id}"
    File.open( zepto_path( zepto_id ), 'w' ) do |f|
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
