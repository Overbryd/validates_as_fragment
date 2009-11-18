module ValidatesAsFragment
  module Validation
    
    def self.included(base)
      base.extend(ClassMethods)
      ActiveRecord::Errors.send(:include, ErrorsExtension)
    end
  
    module ErrorsExtension
      def clear_on(attribute)
        @errors.delete(attribute.to_s)
      end
    end
  
    module ClassMethods
      def validates_as_fragment(options = {})
        include InstanceMethods unless include? InstanceMethods
        options.assert_valid_keys(:indicator, :except)
        write_inheritable_array(:fragment_required_attributes, Array(options[:except]).map(&:to_s))
        write_inheritable_attribute(:fragment_indicator_attribute, options[:indicator] || :invalid)
      end
    end

    module InstanceMethods

      def self.included(base)
        base.class_eval do
          class_inheritable_reader :fragment_required_attributes, :fragment_indicator_attribute
        end
      end

      def valid_fragment?(*attributes)
        invalid =! valid?
        if invalid
          attributes.flatten!
          attributes = attributes.first.keys if attributes.first.is_a?(Hash)
          # handle id and multiparameter attributes such as 'user_id' or 'date(3i)'
          attributes = attributes.map do |attribute|
            attribute = attribute.to_s
            attribute =~ /\([0-9]*([a-z])\)|_id$/ ? $` : attribute
          end
          # merge core attributes that must always be validated
          attributes |= fragment_required_attributes
          # determine attributes that don't need to be validated and remove all errors from these attributes
          attributes = errors.instance_variable_get(:@errors).keys - attributes
          attributes.each{ |attr| errors.clear_on(attr) }
        end
        if fragment_indicator_attribute && ! frozen?
          write_attribute(fragment_indicator_attribute, invalid)
        end
        errors.empty?
      end
    
      def save_fragment!(*attributes)
        if valid_fragment?(*attributes)
          save_without_validation!
        else
          raise ActiveRecord::RecordInvalid.new(self)
        end
      end
  
      def save_fragment(*attributes)
        if valid_fragment?(*attributes)
          save_without_validation
        else
          false
        end
      end
  
      def update_fragment(new_attributes)
        self.attributes = new_attributes
        save_fragment(new_attributes ? new_attributes.keys : nil)
      end

      def update_fragment!(new_attributes)
        self.attributes = new_attributes
        save_fragment!(new_attributes ? new_attributes.keys : nil)
      end
    end
  end
end
