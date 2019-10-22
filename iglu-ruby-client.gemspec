# Copyright (c) 2017 Snowplow Analytics Ltd. All rights reserved.
#
# This program is licensed to you under the Apache License Version 2.0,
# and you may not use this file except in compliance with the Apache License Version 2.0.
# You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the Apache License Version 2.0 is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.

# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iglu-client/version'

Gem::Specification.new do |s|
  s.name        = 'iglu-ruby-client'
  s.version     = Iglu::CLIENT_VERSION
  s.homepage    = 'http://github.com/snowplow/iglu-ruby-client'
  s.license     = 'Apache License 2.0'
  s.summary     = "A Ruby client for Iglu"
  s.description = "Iglu Client is used to resolve JSON Schemas and validate self-describing JSONs"
  s.authors     = ["Anton Parkhomenko"]
  s.email       = 'support@snowplowanalytics.com'
  s.files       = %w(LICENSE-2.0.txt README.md) + Dir.glob('lib/**/*.rb') + Dir.glob('assets/**/*')
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.1.10'
  s.metadata    = {
    'bug_tracker_uri' => 'https://github.com/snowplow/iglu-ruby-client/issues',
    'wiki_uri'        => 'https://github.com/snowplow/iglu/wiki/Ruby-client'
  }

  s.add_runtime_dependency "httparty", "~> 0.15.0"
  s.add_runtime_dependency "json-schema", '>= 2.7.0'
  s.add_development_dependency "rspec", "~> 3.4.0"

end
