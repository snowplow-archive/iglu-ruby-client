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
    config = '{"schema": "iglu:com.snowplowanalytics.iglu/resolver-config/jsonschema/1-0-0", "data": { "cacheSize": 500, "repositories": [ { "name": "Iglu Central", "priority": 1, "vendorPrefixes": [ "com.snowplowanalytics" ], "connection": { "http": { "uri": "http://iglucentral.com" } } } ] } }'
    @json_config = JSON.parse(config, {:symbolize_names => true})

    # cacheSize cannot be null
    invalid_config = '{"schema": "iglu:com.snowplowanalytics.iglu/resolver-config/jsonschema/1-0-0", "data": { "cacheSize": null, "repositories": [ { "name": "Iglu Central", "priority": 1, "vendorPrefixes": [ "com.snowplowanalytics" ], "connection": { "http": { "uri": "http://iglucentral.com" } } } ] } }'
    @json_invalid_config = JSON.parse(invalid_config, {:symbolize_names => true})

    config_with_cacheTtl = '{"schema": "iglu:com.snowplowanalytics.iglu/resolver-config/jsonschema/1-0-2", "data": { "cacheSize": 500, "cacheTtl": 5, "repositories": [ { "name": "Iglu Central", "priority": 0, "vendorPrefixes": [ "com.snowplowanalytics" ], "connection": { "http": { "uri": "http://iglucentral.com" } } } ] } }'
    @json_config_with_cacheTtl = JSON.parse(config_with_cacheTtl, {:symbolize_names => true})

    config_with_null_cacheTtl = '{"schema": "iglu:com.snowplowanalytics.iglu/resolver-config/jsonschema/1-0-2", "data": { "cacheSize": 500, "cacheTtl": null, "repositories": [ { "name": "Iglu Central", "priority": 0, "vendorPrefixes": [ "com.snowplowanalytics" ], "connection": { "http": { "uri": "http://iglucentral.com" } } } ] } }'
    @json_config_with_null_cacheTtl = JSON.parse(config_with_null_cacheTtl, {:symbolize_names => true})
  }

  it 'correctly parses a standard resolver configuration' do
    resolver = Iglu::Resolver.parse(@json_config)
    expect(resolver.registries.size).to eq(2)
    expect(resolver.cacheTtl).to eq(nil)
    expect(resolver.registries[1].config.name).to eq("Iglu Central")
  end

  it 'correctly parses a standard resolver configuration containing cacheTtl (not null)' do
    resolver = Iglu::Resolver.parse(@json_config_with_cacheTtl)
    expect(resolver.registries.size).to eq(2)
    expect(resolver.cacheTtl).to eq(5)
    expect(resolver.registries[1].config.name).to eq("Iglu Central")
  end

  it 'correctly parses a standard resolver configuration containing cacheTtl (null)' do
    resolver = Iglu::Resolver.parse(@json_config_with_null_cacheTtl)
    expect(resolver.registries.size).to eq(2)
    expect(resolver.cacheTtl).to eq(nil)
    expect(resolver.registries[1].config.name).to eq("Iglu Central")
  end

  it 'properly invalidates resolver cache per cacheTtl' do
    resolver = Iglu::Resolver.parse(@json_config_with_cacheTtl)
    expect(resolver.cache.size).to eq(0)
    schema = resolver.lookup_schema(@json_config_with_cacheTtl[:schema])
    expect(resolver.cache.size).to eq(1)
    sleep resolver.cacheTtl
    schema = resolver.lookup_schema(@json_config_with_cacheTtl[:schema])
    expect(schema["self"]["version"]).to eq("1-0-2")
    expect(resolver.cache.size).to eq(1)
  end


  it 'throws an exception on resolver configuration not matching its JSON Schema' do
    expect { Iglu::Resolver.parse(@json_invalid_config) }.to raise_error(JSON::Schema::ValidationError)
  end

  it 'stores schemas in cache' do
    ref_config = Iglu::Registries::RegistryRefConfig.new("Test registry ref", 5, [])
    registry = Iglu::Registries::HttpRegistryRef.new(ref_config, "http://iglucentral.com")
    resolver = Iglu::Resolver.new([registry])
    key1 = Iglu::SchemaKey.new("com.snowplowanalytics.snowplow.enrichments", "api_request_enrichment_config", "jsonschema", Iglu::SchemaVer.new(1,0,0))
    key2 = Iglu::SchemaKey.new("com.snowplowanalytics.snowplow", "duplicate", "jsonschema", Iglu::SchemaVer.new(1,0,0))
    key3 = Iglu::SchemaKey.new("com.snowplowanalytics.iglu", "resolver-config", "jsonschema", Iglu::SchemaVer.new(1,0,0))
    key4 = Iglu::SchemaKey.new("com.snowplowanalytics.iglu", "resolver-config", "jsonschema", Iglu::SchemaVer.new(1,0,0))

    resolver.lookup_schema(key1)
    resolver.lookup_schema(key2)
    resolver.lookup_schema(key2)
    resolver.lookup_schema(key3)
    resolver.lookup_schema(key4)

    expect(resolver.cache.size).to eq(3)
  end

  it 'can lookup schema in bootstrap resolver' do
    schema_key = Iglu::SchemaKey.new("com.snowplowanalytics.iglu", "resolver-config", "jsonschema", Iglu::SchemaVer.new(1,0,0))
    schema = Iglu::Registries.bootstrap.lookup_schema(schema_key)

    config = '{ "$schema": "http://iglucentral.com/schemas/com.snowplowanalytics.self-desc/schema/jsonschema/1-0-0#", "description": "Schema for an Iglu resolver\'s configuration", "self": { "vendor": "com.snowplowanalytics.iglu", "name": "resolver-config", "format": "jsonschema", "version": "1-0-0" }, "type": "object", "properties": { "cacheSize": { "type": "number" }, "repositories": { "type": "array", "items": { "type": "object", "properties": { "name": { "type": "string" }, "priority": { "type": "number" }, "vendorPrefixes": { "type": "array", "items": { "type": "string" } }, "connection": { "type": "object", "oneOf": [ { "properties": { "embedded": { "type": "object", "properties": { "path": { "type": "string" } }, "required": ["path"], "additionalProperties": false } }, "required": ["embedded"], "additionalProperties": false }, { "properties": { "http": { "type": "object", "properties": { "uri": { "type": "string", "format": "uri" } }, "required": ["uri"], "additionalProperties": false } }, "required": ["http"], "additionalProperties": false } ] } }, "required": ["name", "priority", "vendorPrefixes", "connection"], "additionalProperties": false } } }, "required": ["cacheSize", "repositories"], "additionalProperties": false }'

    result = JSON.parse(config)
    expect(schema).to eq(result)

  end
end
