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

    def self.from_json(json)
      new(JSON.parse(json))
    rescue => e
      raise(Errors::JsonParseError, e.message)
    end

    def attributes
      OpenStruct.new(keys: self.class.config[:properties])
    end
  end
end
