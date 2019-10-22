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

require "json-schema"

module Iglu

  # Regular expression to extract metadata from self-describing JSON
  URI_REGEX = Regexp.new "^iglu:([a-zA-Z0-9\\-_.]+)\/([a-zA-Z0-9\\-_]+)\/([a-zA-Z0-9\\-_]+)\/([1-9][0-9]*(?:-(?:0|[1-9][0-9]*)){2})$"

  # Regular expression to extract all parts of SchemaVer: MODEL, REVISION, ADDITION
  SCHEMAVER_REGEX = Regexp.new "^([1-9][0-9]*)-(0|[1-9][0-9]*)-(0|[1-9][0-9]*)$"

  # Class holding SchemaVer data
  class SchemaVer < Struct.new(:model, :revision, :addition)

    # Render as string
    def as_string
      "#{model}-#{revision}-#{addition}"
    end

    # Construct SchemaVer from string
    def self.parse_schemaver(version)
      model, revision, addition = version.scan(SCHEMAVER_REGEX).flatten
      if model.nil? or revision.nil? or addition.nil?
          raise IgluError.new "Schema version #{version} is not a valid Iglu SchemaVer"
      else
          SchemaVer.new model.to_i, revision.to_i, addition.to_i
      end
    end
  end


  # Class holding Schema metadata
  class SchemaKey < Struct.new(:vendor, :name, :format, :version)

    # Render as Iglu URI (with `iglu:`)
    def as_uri
      "iglu:#{as_path}"
    end

    # Render as plain path
    def as_path
      "#{vendor}/#{name}/#{format}/#{version.as_string}"
    end

    # Construct SchemaKey from URI
    def self.parse_key(key)
      vendor, name, format, version = key.scan(URI_REGEX).flatten
      if vendor.nil? or name.nil? or format.nil? or version.nil?
        raise IgluError.new "Schema key [#{key}] is not valid Iglu URI"
      else
        schema_ver = SchemaVer.parse_schemaver(version)
        SchemaKey.new vendor, name, format, schema_ver
      end
    end
  end


  # Custom validator, allowing to use self-describing JSON Schemas
  class SelfDescribingSchema < JSON::Schema::Draft4
    def initialize
      super
      @uri = URI.parse("http://iglucentral.com/schemas/com.snowplowanalytics.self-desc/schema/jsonschema/1-0-0#")
    end

    JSON::Validator.register_validator(self.new)
  end


  # Common Iglu error
  class IgluError < StandardError
    def initialize(message = "Schema not found")
      super(message)
    end
  end
end
