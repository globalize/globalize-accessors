require 'globalize'

module Globalize::Accessors
  def globalize_accessors(options = {})
    options.reverse_merge!(:locales => I18n.available_locales, :attributes => translated_attribute_names)
    class_attribute :globalize_locales, default: options[:locales], instance_writer: false
    class_attribute :globalize_attribute_names, default: [], instance_writer: false

    each_attribute_and_locale(options) do |attr_name, locale|
      localized_attr_name = localized_attr_name_for(attr_name, locale)
      attribute localized_attr_name # needed for dirty tracking
      define_accessors(attr_name, locale)
      self.globalize_attribute_names += [localized_attr_name.to_sym]
    end

    include InstanceMethods
  end

  def localized_attr_name_for(attr_name, locale)
    "#{attr_name}_#{locale.to_s.underscore}"
  end

  private

  def define_accessors(attr_name, locale)
    define_getter(attr_name, locale)
    define_setter(attr_name, locale)
  end

  def define_getter(attr_name, locale)
    generated_attribute_methods.define_method localized_attr_name_for(attr_name, locale) do
      globalize.stash.contains?(locale, attr_name) ? globalize.send(:fetch_stash, locale, attr_name) : globalize.send(:fetch_attribute, locale, attr_name)
    end
  end

  def define_setter(attr_name, locale)
    localized_attr_name = localized_attr_name_for(attr_name, locale)

    generated_attribute_methods.define_method :"#{localized_attr_name}=" do |value|
      write_attribute(localized_attr_name, value) # dirty tracking
      write_attribute(attr_name, value, :locale => locale)
      translation_for(locale)[attr_name] = value
    end
  end

  def each_attribute_and_locale(options)
    options[:attributes].each do |attr_name|
      options[:locales].each do |locale|
        yield attr_name, locale
      end
    end
  end

  module InstanceMethods
    def localized_attr_name_for(attr_name, locale)
      self.class.localized_attr_name_for(attr_name, locale)
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.extend Globalize::Accessors
end
