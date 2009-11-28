module ActiveRecord
  module GlobalizeAccessors
    def self.included(base)
      base.extend ActMethods
    end

    module ActMethods
      def globalize_accessors(*attr_names)
        options = attr_names.extract_options!
        options[:easy_accessors] = attr_names
        
        options[:easy_accessors].each do |attr_name|
          options[:locales].each do |with_locale|
            define_method :"#{attr_name}_#{with_locale}" do
              globalize.fetch with_locale, attr_name
            end
            
            define_method :"#{attr_name}_#{with_locale}=" do |val|
              globalize.stash with_locale, attr_name, val
              self[attr_name] = val
            end
          end
        end
        
        
      end
    end
  end
end