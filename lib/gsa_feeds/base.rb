class GsaFeeds::Base
  def initialize(hostname, datasource = 'web', feedtype = 'incremental', timeout = false)
    @hostname = hostname
    @timeout = timeout || GsaFeeds::TIMEOUT
    @records = []
    @datasource = datasource
    @feedtype = feedtype
  end
  attr_accessor :records, :datasource, :feedtype, :timeout, :hostname
  alias_method :to_a, :records
  
  def clear!
    @records = []
  end

  def add_record(record)
    @records << record
  end

  def build_record(url, options = {}, metadata = nil, content = nil)
    @records << GsaFeeds::Record.new(url, options, metadata, content)
  end

  def commit!
    push_records(@records)
    clear!
    true
  end
  
  def to_xml
    build_xml(@records)
  end
  
private
  
  # def post_form(query, headers, url = "http://#{@hostname}:19900/xmlfeed")
  #   url = URI.parse(url)
  #   Net::HTTP.start(url.host, url.port) do |con|
  #     con.read_timeout = @timeout
  #     return con.post(url.path, query, headers)
  #   end
  # end 
  
  def push_records(records)
    params = Hash.new

    params["data"] = build_xml(records)
    params["datasource"] = @datasource
    params["feedtype"] = @feedtype

    url = URI.parse("http://#{@hostname}:19900/xmlfeed")
    res = Net::HTTP.multi_post_form(url, params)

    # res holds the response to the POST
    case res
    when Net::HTTPSuccess
     return true
    else
      raise "Unknown error #{res}: #{res.inspect}\n#{res.body}"
    end
  end
  
  def build_xml(records)
    string = ''
    builder = Builder::XmlMarkup.new(:target=>string, :indent=>2)
    builder.instruct!
    builder.declare! :DOCTYPE, :gsafeed, :PUBLIC, "-//Google//DTD GSA Feeds//EN", ""
    builder.gsafeed do |feed|
      feed.header do |header|
        header.datasource @datasource
        header.feedtype @feedtype
      end
      feed.group do |r|
        records.each do |record_data|
          if (!record_data.content.nil? || !record_data.metadata.nil?)
            r.record(record_data.to_h) do |record_details|
              unless record_data.metadata.nil?
                record_details.metadata do |meta_tags|
                  record_data.metadata.each do |meta_info|
                    meta_tags.meta(meta_info)
                  end
                end
              end
              record_details.content record_data.content unless record_data.content.nil?
            end
          else
            r.record(record_data.to_h)
          end
        end
      end
    end
    string
  end
  
end