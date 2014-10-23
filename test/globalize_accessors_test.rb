require 'test_helper'

class GlobalizeAccessorsTest < ActiveSupport::TestCase

  class Unit < ActiveRecord::Base
    translates :name, :title
    globalize_accessors
  end

  class UnitTranslatedWithOptions < ActiveRecord::Base
    self.table_name = :units
    translates :name
    globalize_accessors :locales => [:pl], :attributes => [:name]
  end

  class UnitInherited < UnitTranslatedWithOptions
  end

  class UnitInheritedWithOptions < ActiveRecord::Base
    translates :color
    globalize_accessors :locales => [:de], :attributes => [:color]
  end

  if ENV['RAILS_3']
    class UnitWithAttrAccessible < ActiveRecord::Base
      self.table_name = :units
      attr_accessible :name
      translates :name, :title
      globalize_accessors
    end
  end

  class UnitWithDashedLocales < ActiveRecord::Base
    self.table_name = :units
    translates :name
    globalize_accessors :locales => [:"pt-BR", :"en-AU"], :attributes => [:name]
  end

  class UnitWithoutAccessors < ActiveRecord::Base
    self.table_name = :units
  end

  setup do
    assert_equal :en, I18n.locale
  end

  test "return localized attribute names" do
    u = UnitWithDashedLocales.new

    assert_equal "name_en", u.localized_attr_name_for(:name, :en)
    assert_equal "name_pt_br", u.localized_attr_name_for(:name, :"pt-BR")
    assert_equal "name_zh_cn", u.class.localized_attr_name_for(:name, :"zh-CN")
  end

  test "read and write on new object" do
    u = Unit.new(:name_en => "Name en", :title_pl => "Title pl")

    assert_equal "Name en",  u.name
    assert_equal "Name en",  u.name_en
    assert_equal "Title pl", u.title_pl

    assert_nil u.name_pl
    assert_nil u.title_en
  end

  test "build translations for a new object" do
    u = Unit.new(:name_en => "Name en", :title_pl => "Title pl")
    assert_equal 2, u.translations.size # size of the collection
    assert_equal 0, u.translations.count # count from database
  end

  test "doesn't build translations without values" do
    u = Unit.new(:name_en => nil, :title_pl => " ")
    assert_equal 0, u.translations.size
  end

  test "doesn't build translations without values even after saving" do
    u = Unit.new(:name_en => nil, :title_pl => " ")
    u.save

    # On Rails 4, Globalize will always create an empty translation for
    # the default locale
    # On Rails 3, Globalize will always create no translation
    assert (not u.translated_locales.include?(:pl))
  end

  test "persisted translations can be set to empty values" do
    u = Unit.new(:name_en => "test")
    u.save
    u.name_en = ""
    assert_equal "", u.translations.first.name
  end

  test "not persisted translations can be set to empty values" do
    u = Unit.new(:name_en => "test")
    u.name_en = ""
    assert_equal "", u.translations.first.name
  end

  test "write on new object and read on saved" do
    u = Unit.create!(:name_en => "Name en", :title_pl => "Title pl")

    assert_equal "Name en",  u.name
    assert_equal "Name en",  u.name_en
    assert_equal "Title pl", u.title_pl

    assert_nil u.name_pl
    assert_nil u.title_en
  end

   test "updates translations for existing object" do
    u = Unit.create!(:name_en => "Name en", :title_pl => "Title pl")
    u.name_en = "New name en"
    assert_equal "New name en", u.translations.find {|t| t.locale == :en }.name
    assert_equal "Title pl", u.translations.find {|t| t.locale == :pl }.title
    assert_equal 2, u.translations.count
  end

  test "read on existing object" do
    u = Unit.create!(:name_en => "Name en", :title_pl => "Title pl")
    u = Unit.find(u.id)

    assert_equal "Name en",  u.name
    assert_equal "Name en",  u.name_en
    assert_equal "Title pl", u.title_pl

    assert_nil u.name_pl
    assert_nil u.title_en
  end

  test "read and write on existing object" do
    u = Unit.create!(:name_en => "Name en", :title_pl => "Title pl")
    u = Unit.find(u.id)

    u.name_pl = "Name pl"
    u.name_en = "Name en2"
    u.save!

    assert_equal "Name en2",  u.name
    assert_equal "Name en2",  u.name_en
    assert_equal "Name pl",   u.name_pl
    assert_equal "Title pl",  u.title_pl

    assert_nil u.title_en
  end

  test "read and write on class with options" do
    u = UnitTranslatedWithOptions.new()

    assert u.respond_to?(:name_pl)
    assert u.respond_to?(:name_pl=)

    assert ! u.respond_to?(:name_en)
    assert ! u.respond_to?(:name_en=)

    u.name = "Name en"
    u.name_pl = "Name pl"

    assert_equal "Name en",  u.name
    assert_equal "Name pl",  u.name_pl
  end

  if ENV['RAILS_3']
    test "whitelist locale accessors if the original attribute is whitelisted" do
      u = UnitWithAttrAccessible.new()
      u.update_attributes(:name => "Name en", :name_pl => "Name pl", :title => "Title en", :title_pl => "Title pl")

      assert_equal "Name en",  u.name
      assert_equal "Name pl",  u.name_pl
      assert_nil  u.title
      assert_nil  u.title_pl
    end
  end

  test "globalize locales on class without locales specified in options" do
    assert_equal [:en, :pl], Unit.globalize_locales
  end

  test "globalize locales on class with locales specified in options" do
    assert_equal [:pl], UnitTranslatedWithOptions.globalize_locales
  end

  test "read and write on class with dashed locales" do
    u = UnitWithDashedLocales.new()

    assert u.respond_to?(:name_pt_br)
    assert u.respond_to?(:name_pt_br=)

    assert u.respond_to?(:name_en_au)
    assert u.respond_to?(:name_en_au=)

    u.name = "Name en"
    u.name_pt_br = "Name pt-BR"
    u.name_en_au = "Name en-AU"

    assert_equal "Name en",  u.name
    assert_equal "Name pt-BR",  u.name_pt_br
    assert_equal "Name en-AU",  u.name_en_au
  end

  test "read when fallbacks present" do
    u = Unit.create!(:name_en => "Name en", :title_pl => "Title pl")
    u = Unit.find(u.id)
    def u.globalize_fallbacks(locale)
      locale == :pl ? [:pl, :en] : [:en, :pl]
    end

    assert_equal "Name en",  u.name
    assert_nil u.title_en
  end

  test "globalize attribute names on class without attributes specified in options" do
    assert_equal [:name_en, :name_pl, :title_en, :title_pl], Unit.globalize_attribute_names
  end

  test "globalize attribute names on class with attributes specified in options" do
    assert_equal [:name_pl], UnitTranslatedWithOptions.globalize_attribute_names
  end

  test "inherit globalize locales and attributes" do
    assert_equal [:name_pl], UnitInherited.globalize_attribute_names
    assert_equal [:pl], UnitInherited.globalize_locales
  end

  test "overwrite inherited globalize locales and attributes" do
    assert_equal [:color_de], UnitInheritedWithOptions.globalize_attribute_names
    assert_equal [:de], UnitInheritedWithOptions.globalize_locales
  end

  test "instance cannot set globalize locales or attributes" do
    assert_raise(NoMethodError) { Unit.new.globalize_attribute_names = [:name] }
    assert_raise(NoMethodError) { Unit.new.globalize_locales = [:en, :de] }
  end

  test "instance without accessors" do
    refute UnitWithoutAccessors.new.respond_to?(:localized_attr_name_for)
  end
end
