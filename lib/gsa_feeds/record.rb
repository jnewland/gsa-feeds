class GsaFeeds::Record
  def initialize(url, options = {}, metadata = nil, content = nil)
    options = {:mimetype => 'text/html'}.merge(options)
    @hash = options.merge({:url => url})
    @metadata = metadata
    @content = content
  end
  attr_accessor :hash, :metadata, :content
  
  #automap the metadata hash into an array name / content pairs
  def metadata
    @metadata.map { |key, value| {:name => key, :content => value } } rescue nil
  end
  
  def to_h
    @hash
  end
end