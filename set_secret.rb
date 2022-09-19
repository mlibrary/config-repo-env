#!env ruby

require "rbnacl"
require "base64"
require "faraday"
require "faraday/net_http"
require "optparse"

$LOAD_PATH.unshift(File.dirname(File.realpath($0)) + "/lib")

require "repository_secret"

usage = "Usage: #{$0} [-e ENVIRONMENT] organization/repository SECRET_NAME < secret_value"
environment = nil

OptionParser.new do |opts|
  opts.banner = usage

  opts.on("-e", "--environment=NAME", "Environment name") do |e|
    environment = e
  end
end.parse!

unless ARGV.length == 2
  puts "Repository and secret name are both required."
  puts
  puts usage
  exit
end

(repository, secret_name) = ARGV
secret_value = $stdin.read

RepositorySecret.new(repository, environment).add(secret_name, secret_value)
