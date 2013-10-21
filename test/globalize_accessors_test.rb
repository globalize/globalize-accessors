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

  class UnitWithAttrAccessible < ActiveRecord::Base
    self.table_name = :units
    attr_accessible :name if ENV['RAILS_3']
    translates :name, :title
    globalize_accessors
  end

  class UnitWithDashedLocales < ActiveRecord::Base
    self.table_name = :units
    translates :name
    globalize_accessors :locales => [:"pt-BR", :"en-AU"], :attributes => [:name]
  end

  setup do
    assert_equal :en, I18n.locale
  end

  test "read and write on new object" do
    u = Unit.new(:name_en => "Name en", :title_pl => "Title pl")

    assert_equal "Name en",  u.name
    assert_equal "Name en",  u.name_en
    assert_equal "Title pl", u.title_pl

    assert_nil u.name_pl
    assert_nil u.title_en
  end

  test "write on new object and read on saved" do
    u = Unit.create!(:name_en => "Name en", :title_pl => "Title pl")

    assert_equal "Name en",  u.name
    assert_equal "Name en",  u.name_en
    assert_equal "Title pl", u.title_pl

    assert_nil u.name_pl
    assert_nil u.title_en
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
end
