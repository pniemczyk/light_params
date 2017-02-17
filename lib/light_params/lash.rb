require 'active_model'

module LightParams
  class Lash < Hash
    include PropertiesConfiguration
    include ActiveModel::Serializers::JSON

    def initialize(params = {})
      LashBuilder.lash_params(self, params).each_pair do |k, v|
        self[k.to_sym] = v
      end
    end

    def self.name
      @name || super
    end

    def self.from_json(json, include_root = false)
      hash = JSON.parse(json)
      hash = hash.values.first if include_root
      new(hash)
    rescue => e
      raise(Errors::JsonParseError, e.message)
    end

    def attributes
      OpenStruct.new(keys: self.class.config[:properties])
    end

    private

    def include_root_in_json
      false
    end
  end
end
