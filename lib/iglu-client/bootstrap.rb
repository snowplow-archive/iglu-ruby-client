module Iglu
  module Registries
    config = Iglu::Registries::RegistryRefConfig.new "Iglu Client Embedded", 0, []
    root = File.dirname(Iglu::Resolver.method(:parse).source_location[0])
    path = File.join(root, '..', '..', 'assets', "iglu-client-embedded")

    @@registry = Iglu::Registries::EmbeddedRegistryRef.new(config, path)

    # Registry embedded straight into iglu-client gem
    def self.bootstrap
      @@registry
    end
  end
end
