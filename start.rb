require 'ramaze'

# By Pistos
# http://blog.purepistos.net
# Clever id<->index mapping algorithm by manveru.


class MainController < Ramaze::Controller
  MAP_DIR = "mapping"
  # If you change ID_CHARS ensure that it's filesystem safe.
  ID_CHARS = (48..128).map{ |c| c.chr }.grep( /[[:alnum:]]/ )
  ZEPTO_URI_BASE = "http://zep.purepistos.net/"
  
  def initialize
    if not File.exist?( MAP_DIR )
      FileUtils.mkdir MAP_DIR
    end
    @mutex = Mutex.new
  end
  
  # Redirect using zepto id, or show home page.
  def index( id = nil )
    if id
      index = id_to_index( id )
      path = zepto_path( index )
      if File.exists?( path ) and File.file?( path )
        uri = File.read( path ).strip
        if not uri.empty?
          t = Time.now
          File.utime( t, t, path )
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
    next_index = nil
    zepto_id = nil
    @mutex.synchronize do
      next_index = ( Dir[ "#{MAP_DIR}/*" ].map { |path| File.basename( path ).to_i }.max || 0 ) + 1
      zepto_id = index_to_id( next_index )
      File.open( zepto_path( next_index ), 'w' ) do |f|
        f.puts uri
      end
    end
    
    @zepto_uri = "#{ZEPTO_URI_BASE}#{zepto_id}"
    @original_uri = uri
  end
  
  def error
    "Huh? 404! Or is that 500? <a href='/'>Home</a>"
  end
  
  # ---------------------------------------------------------
  
  def index_to_id( index )
    r = 0
    zepto_id = ""
    while index > 0
      index, r = index.divmod ID_CHARS.size
      zepto_id << ID_CHARS[ r ]
    end
    zepto_id
  end
  private :index_to_id
  
  def id_to_index( id )
    index, r = 0, 0
    id.scan( /./ ) do |c|
      r = ID_CHARS.index( c )
      index = index * ID_CHARS.size + r
    end
    index
  end
  private :id_to_index
  
  def zepto_path( id )
    "#{MAP_DIR}/#{id}"
  end
  private :zepto_path
end

Ramaze.start :adapter => :mongrel, :port => 8006
