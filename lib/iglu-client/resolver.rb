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

require "httparty"
require "json-schema"

module Iglu

  # Iglu Client. Able to fetch schemas only from Iglu Central
  class Resolver
    attr_reader :registries, :cache, :cacheTtl

    def initialize(registries, cacheTtl=nil)
      @registries = registries.unshift(Registries.bootstrap)
      @cache = Hash.new
      @cacheTtl = cacheTtl
    end

    # Lookup schema in cache or try to fetch
    def lookup_schema(schema_key)
      lookup_time = Time.now.getutc
      if schema_key.is_a?(String)
        schema_key = SchemaKey.parse_key(schema_key)
      end
      failures = []

      cache_result = @cache[schema_key]
      if not cache_result.nil?
        if not @cacheTtl.nil?
          store_time = cache_result[1]
          time_diff = (lookup_time - store_time).round
          if time_diff >= @cacheTtl
            @cache.delete(schema_key)
            cache_result = nil
          else
            return cache_result[0]
          end
        else
          return cache_result[0]
        end
      end

      if cache_result.nil?          # Fetch from every registry
        for registry in prioritize_repos(schema_key, @registries) do
          begin
            lookup_result = registry.lookup_schema(schema_key)
          rescue StandardError => e
            failures.push(Registries::LookupFailure.new(registry.config.name, e))
          else
            if lookup_result.nil?
              failures.push(Registries::NotFound.new(registry.config.name))
            else
              break
            end
          end
        end

        if lookup_result.nil?
          raise Registries::ResolverError.new(failures, schema_key)
        else
          store_time = Time.now.getutc
          @cache[schema_key] = [lookup_result, store_time]
          lookup_result
        end
      end
    end

    def self.parse(json)
      schema_key = Resolver.get_schema_key(json)
      schema = Registries.bootstrap.lookup_schema(schema_key)
      data = get_data(json)
      if JSON::Validator.validate!(schema, data)
        registries = data[:repositories].map do |registry| parse_registry(registry) end
        cacheTtl = json[:data][:cacheTtl]
        Resolver.new(registries, cacheTtl)
      else
        throw IgluError.new "Invalid resolver configuration"
      end
    end

    def self.parse_registry(config)
      ref_config = Registries::RegistryRefConfig.parse(config)
      if not config[:connection][:embedded].nil?
        Registries::EmbeddedRegistryRef.new(ref_config, config[:connection][:embedded][:path])
      elsif not config[:connection][:http].nil?
        Registries::HttpRegistryRef.new(ref_config, config[:connection][:http][:uri])
      else
        raise IgluError.new "Incorrect RegistryRef"
      end
    end

    def self.get_schema_key(json)
      schema_uri = json[:schema] || json["schema"]
      if schema_uri.nil?
        raise IgluError.new "JSON instance is not self-describing (schema property is absent):\n #{json.to_json}"
      else
        SchemaKey.parse_key schema_uri
      end
    end

    def self.get_data(json)
      data = json[:data] || json["data"]
      if data.nil?
        raise IgluError.new "JSON instance is not self-describing (data proprty is absent):\n #{json.to_json}"
      else
        data
      end
    end

    # Return true or throw exception
    def validate(json)
      schema_key = Resolver.get_schema_key json
      data = Resolver.get_data json
      schema = lookup_schema schema_key
      JSON::Validator.validate!(schema, data)
    end

    def prioritize_repos(schema_key, repository_refs)
      repository_refs.sort_by do |ref|
        [Resolver.btoi(!ref.vendor_matched(schema_key)), ref.class_priority, ref.config.priority]
      end
    end

    # Convert boolean to int
    def self.btoi(b)
      if b then 1 else 0 end
    end
  end
end
