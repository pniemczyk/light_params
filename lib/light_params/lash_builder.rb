module LightParams
  class LashBuilder
    class << self
      def lash_params(lash, params)
        return {} if params.nil? || lash.class.config[:properties].nil? || lash.class.config[:properties].empty?
        prepare_params(lash, params)
      end

      private

      def prepare_params(lash, params)
        properties_sources       = lash.class.config[:properties_sources] || {}
        properties_modifications = lash.class.config[:properties_modifications] || {}

        {}.tap do |result|
          lash.class.config[:properties].each do |key|
            modification = properties_modifications[key] || {}
            value        = hash_value(params, (modification[:from] || key))
            fail(MissingParamError, key.to_s) if modification[:required] && value.nil?
            next result[key] = (modification[:default] || value) if value.nil? || value.empty?
            value = prepare_sources(properties_sources[key], value) if properties_sources[key]
            value = transform_value(modification[:with], lash, key, value) if modification[:with]
            next result[key] = modelable_value(modification[:model], value) if modification[:model]
            next result[key] = collectionaize_value(modification, value) if modification[:collection]
            result[key] = value
          end
        end
      end

      def hash_value(hash, key)
        hash[key] || hash[key.to_s]
      end

      def prepare_sources(source, value)
        value.is_a?(Array) ? value.map { |s| source[:class].new(s) } : source[:class].new(value)
      end

      def transform_value(transformation, lash, key, value)
        trans_proc = transformation.is_a?(Proc) ? transformation : lash.method(transformation)
        trans_proc.call(value)
      rescue => e
        raise Errors::ValueTransformationError, "key #{key}: #{e.message}"
      end

      def modelable_value(model_class, value)
        model_class.new(value)
      end

      def collectionaize_value(modifications, value)
        collection = modifications[:collection]
        fail(Errors::MissingCollectionError, "on key: #{key}") unless value.is_a? Array
        value.uniq! if modifications[:uniq]
        value.compact! if modifications[:compact]
        return value if collection == true
        value.compact.uniq.map { |source| collection.new(source) }
      end
    end
  end
end
