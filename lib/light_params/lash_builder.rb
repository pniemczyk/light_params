module LightParams
  class LashBuilder
    class << self
      def lash_params(lash, params)
        prepare_params(lash, params || {})
      end

      private

      def prepare_params(lash, params)
        properties               = lash.class.config[:properties] ||= params.keys.map(&:to_sym)
        properties_sources       = lash.class.config[:properties_sources] || {}
        properties_modifications = lash.class.config[:properties_modifications] || {}

        {}.tap do |result|
          properties.each do |key|
            modification = properties_modifications[key] || {}
            value        = hash_value(params, (modification[:from] || key))
            raise(MissingParamError, key.to_s) if modification[:required] && value.nil?
            next result[key] = (modification[:default] || (modification[:collection] ? [] : value)) if value.nil? || value.empty?
            value = prepare_sources(properties_sources[key], value) if properties_sources[key]
            value = transform_value(modification[:with], lash, key, value) if modification[:with]
            next result[key] = modelable_value(modification[:model], value) if modification[:model]
            next result[key] = collectionaize_value(modification, value, properties_sources[key]) if modification[:collection]
            result[key] = value
          end
        end
      end

      def hash_value(hash, key)
        hash[key] || hash[key.to_s]
      end

      def prepare_sources(source, value)
        value.is_a?(Array) ? value.map { |s| source[:class].new(s) if s } : source[:class].new(value)
      end

      def transform_value(transformation, lash, key, value)
        trans_proc = transformation.is_a?(Proc) ? transformation : lash.method(transformation)
        trans_proc.call(value)
      rescue => e
        raise Errors::ValueTransformationError, "key #{key}: #{e.message}"
      end

      def modelable_value(model_class, value)
        # _save_source_params(key, params[key])
        model_class.new(value)
      end

      # def _save_source_params(key, params)
      #   _properties_sources[key][:params] = params.clone if _properties_sources[key]
      # end

      def collectionaize_value(modifications, value, sourced)
        collection = modifications[:collection]
        raise(Errors::MissingCollectionError, "on key: #{key}") unless value.is_a? Array
        value.compact! if modifications[:compact]
        value.uniq! if modifications[:uniq]
        if collection == true
          sourced ? value : value.map { |v| v.is_a?(Hash) ? Lash.new(v) : v }
        else
          # _save_source_params(key, array.compact)
          value.map { |source| collection.new(source) if source }
        end
      end
    end
  end
end
