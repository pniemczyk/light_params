module LightParams
  class Lash < Hash
    include PropertiesConfiguration

    def initialize(params = {})
      LashBuilder.lash_params(self, params).each_pair do |k, v|
        self[k.to_sym] = v
      end
    end

    def self.name
      @name || super
    end

    # def attributes
    #   OpenStruct.new(keys: self.class.config[:properties])
    # end

  end
end
