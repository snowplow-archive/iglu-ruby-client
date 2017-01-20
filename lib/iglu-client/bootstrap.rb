module Iglu
  module Registries
    config = Iglu::Registries::RegistryRefConfig.new "Iglu Client Embedded", 0, []
    @@registry = Iglu::Registries::EmbeddedRegistryRef.new config, "iglu-client-embedded"

    # Registry embedded straight into iglu-client gem
    def self.bootstrap
      @@registry
    end
  end
end
