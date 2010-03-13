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
              if @temp_attributes and @temp_attributes[with_locale][attr_name]
                @temp_attributes[with_locale][attr_name]
              else
                globalize.fetch with_locale, attr_name
              end
            end

            define_method :"#{attr_name}_#{with_locale}=" do |val|
              initialize_temp_attributes unless @temp_attributes
              @temp_attributes[with_locale][attr_name] = val
              globalize.stash.write with_locale, attr_name, val
              self[attr_name] = val
            end
          end
        end
         
        define_method :initialize_temp_attributes do
          @temp_attributes = Hash[*languages.collect { |v| [v, {}]}.flatten]
        end
        
        after_save :initialize_temp_attributes 
      end
    end
  end
end
