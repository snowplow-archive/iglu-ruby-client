require 'json'

module Iglu
  module Registries
    class RegistryRefConfig
      attr_reader :name, :priority, :vendor_prefixes

      def initialize(name, priority, vendor_prefixes)
        @name = name
        @priority = priority
        @vendor_prefixes = vendor_prefixes
      end

      def self.parse(config)
        RegistryRefConfig.new config[:name], config[:priority], config[:vendorPrefixes]
      end
    end

    # Interface
    class RegistryRef
      attr_reader :config, :class_priority, :descriptor

      def lookup_schema(schema_key)
      end

      def vendor_matched(schema_key)
        matches = @config.vendor_prefixes.map { |p|
          schema_key.vendor.start_with?(p)
        }
        matches.include? true
      end
    end

    class HttpRegistryRef < RegistryRef

      def initialize(config, uri)
        @config = config
        @class_priority = 100
        @descriptor = "HTTP"

        @uri = uri
      end

      def lookup_schema(schema_key, max_retries = 3)
        schema_uri = "#{@uri}/schemas/#{schema_key.as_path}"
        times_retried = 0

        begin
          response = HTTParty.get(schema_uri, timeout: 3)
        rescue SocketError => _
          raise IgluError.new "Iglu registry #{config.name} is not available"
        rescue Net::ReadTimeout => e
          if times_retried < max_retries
            times_retried += 1
            retry
          else
            raise e
          end
        end

        if response.code == 200
          JSON::parse(response.body)
        else
          nil
        end
      end
    end

    # This is not a replacement for JVM Embedded Registry
    # It is something more like FileSystemRegistry if you pass absolute path,
    # But by default it's root is relative to gem
    class EmbeddedRegistryRef < RegistryRef
      def initialize(config, path)
        @config = config
        @class_priority = 1
        @descriptor = "embedded"

        @root = path
      end

      def lookup_schema(schema_key)
        schema_path = File.join(@root, 'schemas', schema_key.as_path)
        content = File.read(schema_path)
        JSON::parse(content)
      rescue Errno::ENOENT => _
        nil
      end
    end

    # Lookup results

    class NotFound
      attr_reader :registry

      def initialize(registry)
        @registry = registry
      end

      def to_s
        "Not found at #{@registry}"
      end
    end

    class LookupFailure
      attr_reader :registry, :reason

      def initialize(registry, reason)
        @reason = reason
        @registry = registry
      end

      def to_s
        "Lookup failure at #{@registry} because #{@reason}"
      end
    end

    class ResolverError < StandardError
      attr_reader :lookups, :schema_key

      def initialize(lookups, schema_key)
        @lookups = lookups
        @schema_key = schema_key
        message = "Schema [#{schema_key.as_uri}] was not found with in [#{lookups.length}] registries with following attempts: [#{lookups.map { |lookup| lookup.to_s }.join('; ')}]"
        super(message)
      end
    end

  end
end
