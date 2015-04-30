require 'set'
require 'active_support'

module LightParams
  module PropertiesConfiguration
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def config
        @config ||= {}
      end

      def properties(*prop_names)
        opts = prop_names.last.is_a?(Hash) ? prop_names.pop : nil
        prop_names.each do |prop_name|
          _add_property(prop_name)
          _add_property_modifications(prop_name, opts || {})
        end
      end

      def property(prop_name, options = {}, &block)
        _add_property(prop_name)
        _add_property_modifications(prop_name, options)
        # _add_property_validation(prop_name, options[:validates]) if options[:validates]
        _add_property_source(prop_name, &block) if block
      end

      private

      def _add_property_source(prop_name, &block)
        klass = Class.new(self)
        klass.instance_variable_set(:@config, {})
        klass.instance_variable_set(:@name, ActiveSupport::Inflector.classify(prop_name))
        klass.class_eval(&block)
        _properties_sources[prop_name] = { class: klass }
      end

      def _properties_sources
        config[:properties_sources] ||= {}
      end

      def _properties_modifications
        config[:properties_modifications] ||= {}
      end

      def _properties
        config[:properties] ||= Set.new
      end

      def _add_property_modifications(prop_name, options = {})
        modifications = options.slice(:from, :with, :default, :model, :collection, :uniq, :compact, :required)
        return if modifications.empty?
        _properties_modifications[prop_name] = modifications
      end

      # def _add_property(prop_name)
      #   send(:attr_accessor, prop_name)  if _properties.add?(prop_name)
      # end

      def _add_property(prop_name)
        return unless _properties.add?(prop_name)
        define_method(prop_name) { |&block| self.[](prop_name, &block) }
        property_assignment = "#{prop_name}=".to_sym
        define_method(property_assignment) { |value| self.[]=(prop_name, value) }
      end

      # def _add_property_validation(prop_name, validation)
      #   validates(prop_name, validation)
      # end
    end

    def respond_to?(method_name, include_private = false)
      return _properties.include?(method_name.to_s.delete('=').to_sym) unless super
      false
    end

    private

    def _properties
      self.class.config[:properties] || {}
    end

    def method_missing(method, *args, &block)
      method_writer = method.to_s[-1] == '='
      return (method_writer ? self.[]=(method.to_s[-1].to_sym, *args, &block) : self.[](method, *args, &block)) if respond_to?(method)
      super
    end

    def attributes
      OpenStruct.new(keys: _properties)
    end
  end
end
