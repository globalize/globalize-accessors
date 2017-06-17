# Adds :confirmable option to globalize_accessors,
# which is stored in the translations table for that model
#
# Adds these methods for each globalize_accessors attributes:
#
#   {attr}_confirmed?(locale)
#   {attr}_mark_confirmed!(locale)
#   {attr}_mark_unconfirmed!(locale)
#
# You must add a migration for each globalized table,
# using add_globalize_confirmed_column! and remove_globalize_confirmed_column!
#

module Globalize::Confirmable
  COLUMN_NAME = 'confirmed'.freeze

  def use_globalize_confirmable?
    return true if supports_globalize_confirmable?

    Rails.logger.warn("Globalize::Confirmable column is not present on #{self.class.name}."\
                      "Use the #add_globalize_confirmed_column! method to add it.")

    false
  end

  def add_confirmable_class_methods
    # Setup the confirmed column as an array
    translation_class.send(:serialize, COLUMN_NAME, Array)
  end

  def define_confirmable_instance_methods(attr_name)
    define_confirmed_method(attr_name)
    define_mark_confirmed_method(attr_name)
    define_mark_unconfirmed_method(attr_name)
  end

  # Helpers to add Globalize::Confirmable to any model
  #
  # e.g. in a migration:
  # def up; Post.add_globalize_confirmed_column!; end

  def add_globalize_confirmed_column!
    add_column translations_table_name, COLUMN_NAME, :string
  end

  def remove_globalize_confirmed_column!
    remove_column translations_table_name, COLUMN_NAME, :string
  end

  private

  def define_confirmed_method(attr_name)
    define_method :"#{attr_name}_confirmed?" do |locale|
      return false if new_record?
      tfl = translation_for(locale)
      tfl.present? && tfl.confirmed.include?(attr_name)
    end
  end

  def define_mark_confirmed_method(attr_name)
    define_method :"#{attr_name}_mark_confirmed!" do |locale|
      return true if send(:"#{attr_name}_confirmed?", locale)
      tfl = translation_for(locale)
      tfl.present? && tfl.update_attributes(confirmed: tfl.confirmed.push(attr_name))
    end
  end

  def define_mark_unconfirmed_method(attr_name)
    define_method :"#{attr_name}_mark_unconfirmed!" do |locale|
      return true unless send(:"#{attr_name}_confirmed?", locale)
      tfl = translation_for(locale)
      tfl.present? && tfl.update_attributes(confirmed: tfl.confirmed.delete(locale))
    end
  end

  def supports_globalize_confirmable?
    translation_class.column_names.include?(COLUMN_NAME)
  end
end

ActiveRecord::Base.extend Globalize::Confirmable
