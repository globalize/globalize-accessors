require 'globalize'

module Globalize::Accessors
  def globalize_accessors(options = {})
    options.reverse_merge!(:locales => I18n.available_locales, :attributes => translated_attribute_names)
    class_attribute :globalize_locales, :globalize_attribute_names, :instance_writer => false

    self.globalize_locales = options[:locales]
    self.globalize_attribute_names = []

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
      globalize.stash.contains?(locale, attr_name) ? globalize.send(:fetch_stash, locale, attr_name) : globalize.send(:fetch_attribute, locale, attr_name)
    end
  end

  def define_setter(attr_name, locale)
    localized_attr_name = "#{attr_name}_#{locale.to_s.underscore}"

    define_method :"#{localized_attr_name}=" do |value|
      write_attribute(attr_name, value, :locale => locale)
      translation_for(locale)[attr_name] = value if value.present?
    end
    if respond_to?(:accessible_attributes) && accessible_attributes.include?(attr_name)
      attr_accessible :"#{localized_attr_name}"
    end
    self.globalize_attribute_names << localized_attr_name.to_sym
  end

  def each_attribute_and_locale(options)
    options[:attributes].each do |attr_name|
      options[:locales].each do |locale|
        yield attr_name, locale
      end
    end
  end

end

ActiveRecord::Base.extend Globalize::Accessors
