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

require 'json'
require 'json-schema'
require 'spec_helper'

describe Iglu do

  before {
    ref_config = Iglu::Registries::RegistryRefConfig.new("Test registry ref", 5, [])
    registry = Iglu::Registries::HttpRegistryRef.new(ref_config, "http://iglucentral.com")
    @resolver = Iglu::Resolver.new([registry])
  }

  it 'correctly parses and validate a self-describing JSON' do
    instance = '{"schema": "iglu:com.parrable/decrypted_payload/jsonschema/1-0-0", ' \
               ' "data": {' \
               '   "browserid": "9b5cfd54-3b90-455c-9455-9d215ec1c414",' \
               '   "deviceid": "asdfasdfasdfasdfcwer234fa$#ds±f324jo"' \
               ' }' \
               '}'
    expect(Iglu::SelfDescribingJson.parse_json(JSON.parse(instance)).valid?(@resolver)).to eq(true)
  end

  it 'correctly parses and invalidate an invalid self-describing JSON' do
    instance = '{"schema": "iglu:com.parrable/decrypted_payload/jsonschema/1-0-0", ' \
               ' "data": {' \
               '   "browserid": "9b5cfd54-3b90-455c-9455-9d215ec1c414",' \
               '   "deviceid": "asdfasdfasdfasdfcwer234fa$#ds±f324joa"' \
               ' }' \
               '}'
    expect(Iglu::SelfDescribingJson.parse_json(JSON.parse(instance)).valid?(@resolver)).to eq(false)
  end

  it 'correctly parses Iglu URI into object' do
    expect(Iglu::SchemaKey.parse_key("iglu:com.snowplowanalytics.snowplow/event/jsonschema/1-0-1")).to eq(Iglu::SchemaKey.new("com.snowplowanalytics.snowplow", "event", "jsonschema", Iglu::SchemaVer.new(1, 0, 1)))
  end

  it 'correctly parses SchemaVer into object (single-digit versions)' do
    expect(Iglu::SchemaVer.parse_schemaver("2-0-3")).to eq(Iglu::SchemaVer.new(2, 0, 3))
  end

  it 'correctly parses SchemaVer into object (multiple-digits versions)' do
    expect(Iglu::SchemaVer.parse_schemaver("10-0-112")).to eq(Iglu::SchemaVer.new(10, 0, 112))
  end

  it 'throws exception on an incorrect SchemaVer (letter-digit mixed)' do
    expect { Iglu::SchemaVer.parse_schemaver("10-a-1") }.to raise_error(Iglu::IgluError)
  end

  it 'throws exception on an incorrect SchemaVer (with lower case letters)' do
    expect { Iglu::SchemaVer.parse_schemaver("a-b-c") }.to raise_error(Iglu::IgluError)
  end

  it 'throws exception on an incorrect SchemaVer (with upper case letters)' do
    expect { Iglu::SchemaVer.parse_schemaver("A-B-C") }.to raise_error(Iglu::IgluError)
  end

  it 'throws exception on an incorrect SchemaVer (dot formatted)' do
    expect { Iglu::SchemaVer.parse_schemaver("2.0.3") }.to raise_error(Iglu::IgluError)
  end

  it 'throws exception on an incorrect SchemaKey (without iglu protocol)' do
    expect { Iglu::SchemaKey.parse_key("com.snowplowanalytics.snowplow/event/jsonschema/1-0-1") }.to raise_error(Iglu::IgluError)
  end

  it 'throws exception on an incorrect SchemaKey (with incorrect SchemaVer)' do
    expect { Iglu::SchemaKey.parse_key("iglu:com.snowplowanalytics.snowplow/event/jsonschema/1-a-1") }.to raise_error(Iglu::IgluError)
  end

  it 'correctly parses and validate a self-describing JSON' do
    instance = '{"schema": "iglu:com.parrable/decrypted_payload/jsonschema/1-0-0", ' \
               ' "data": {' \
               '   "browserid": "9b5cfd54-3b90-455c-9455-9d215ec1c414",' \
               '   "deviceid": "asdfasdfasdfasdfcwer234fa$#ds±f324jo"' \
               ' }' \
               '}'
    json = JSON::parse(instance)
    expect(@resolver.validate(json)).to eq(true)
  end

  it 'correctly invalidates self-describing JSON (wrong string length) by returning exception' do
    instance = '{"schema": "iglu:com.parrable/decrypted_payload/jsonschema/1-0-0", ' \
               ' "data": {' \
               '   "browserid": "9b5cfd54-3b90-455c-9455-9d215ec1c414",' \
               '   "deviceid": "asdfasdfasdfasdfcwer234fa$#ds±f324joa"' \
               ' }' \
               '}'
    json = JSON::parse(instance)
    expect { @resolver.validate(json) }.to raise_error(JSON::Schema::ValidationError)
  end
end
