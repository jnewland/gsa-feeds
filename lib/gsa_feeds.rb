$:.unshift File.dirname(__FILE__)
require 'net/http'
require 'multipart'
require 'builder'
module GsaFeeds
  TIMEOUT = 60
end
require 'gsa_feeds/base'
require 'gsa_feeds/record'