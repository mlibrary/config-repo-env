#!env ruby

require "rbnacl"
require "base64"
require "faraday"
require "faraday/net_http"
require "optparse"

$LOAD_PATH.unshift(File.dirname(File.realpath($0)) + "/lib")

require "repository_secret"

usage = "Usage: #{$0} [-e ENVIRONMENT] organization/repository SECRET_NAME secret_value"

unless ARGV.length == 3
  puts "Repository, secret name, and value are all required"
  puts
  puts usage
  exit
end

(repository, secret_name, secret_value) = ARGV

RepositorySecret.new(repository).add(secret_name, secret_value)
