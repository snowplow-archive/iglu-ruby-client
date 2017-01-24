#!/usr/bin/env ruby

require_relative "../lib/iglu/version.rb" 

travis_tag = ARGV[0]

if Iglu::Client::VERSION != travis_tag then
    STDERR.puts "Tag \"#{travis_tag}\" does not match version.rb (#{Iglu::Client::VERSION})"
    exit 1
else
    exit 0
end 

