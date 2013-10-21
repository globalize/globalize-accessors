require 'globalize'

module GlobalizeAccessors
  attr_reader :globalize_locales

  def globalize_accessors(options = {})
    options.reverse_merge!(:locales => I18n.available_locales, :attributes => translated_attribute_names)
    @globalize_locales = options[:locales]

    each_attribute_and_locale(options) do |attr_name, locale|
      define_accessors(attr_name, locale)
    end
  end


  private


  def define_accessors(attr_name, locale)
    define_getter(attr_name, locale)
    define_setter(attr_name, locale)
  end


  def define_getter(attr_name, locale)
    define_method :"#{attr_name}_#{locale.to_s.underscore}" do
      read_attribute(attr_name, :locale => locale)
    end
  end

  def define_setter(attr_name, locale)
    define_method :"#{attr_name}_#{locale.to_s.underscore}=" do |value|
      write_attribute(attr_name, value, :locale => locale)
    end
    if respond_to?(:accessible_attributes) && accessible_attributes.include?(attr_name)
      attr_accessible :"#{attr_name}_#{locale.to_s.underscore}"
    end
  end

  def each_attribute_and_locale(options)
    options[:attributes].each do |attr_name|
      options[:locales].each do |locale|
        yield attr_name, locale
      end
    end
  end

end

ActiveRecord::Base.extend GlobalizeAccessors
