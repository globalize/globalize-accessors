module ActiveRecord
  module GlobalizeAccessors
    def self.included(base)
      base.extend ActMethods
    end
    
    module ActMethods
      def globalize_accessors(*attr_names)
        languages = attr_names
        attribs = translated_attribute_names
        attribs.each do |attr_name|
          languages.each do |with_locale|
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
