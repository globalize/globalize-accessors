# Globalize Accessors [![Build Status](https://travis-ci.org/globalize/globalize-accessors.png?branch=master)](https://travis-ci.org/globalize/globalize-accessors)

## Introduction

Generator of accessor methods for models using Globalize. Use `globalize-accessors` with a list of translated fields you want easily access to and extra `locales` array listing locales for which you want the accessors to be generated.

This way a single form can be used to edit given model fields with all anticipated translations.

`globalize-accessors` is compatible with both Rails 3.x and Rails 4.


## Installation

````ruby
gem install globalize-accessors
````

## Example

Definition like this:

````ruby
class Product
  translates :title, :description
  globalize_accessors :locales => [:en, :pl], :attributes => [:title]
end
````

Gives you access to methods: `title_pl`, `title_en`, `title_pl=`, `title_en=`. These work seamlessly with Globalize (not even touching the "core" `title`, `title=` methods used by Globalize itself).

The `:locales` and `:attributes` options are optional. Their default values are:

````ruby
:locales => I18n.available_locales
:attributes => translated_attribute_names
````

Calling `globalize_accessors` with no options will therefore generate accessor methods for all translated fields and available languages.

You can also get the accessor locales for a class with the `globalize_locales` method:

````ruby
Product.globalize_locales # => [:en, :pl]
````

You can also get modified attribute names -- ideal for use with strong parameters -- with the `globalize_attribute_names` method:

````ruby
Product.globalize_attribute_names # => [:title_en, :title_pl]
````

Example with strong parameters:

````ruby
params.require(:product).permit(*Product.globalize_attribute_names)
````

If you need to permit non-translatable attributes as well, you could include them with:

````ruby
permitted = Product.globalize_attribute_names + [:position]
params.require(:product).permit(*permitted)
````

## Always define accessors

If you wish to always define accessors and don't want to call the `globalize_accessors` method in every class, you can extend `ActiveRecord::Base` with a module:

````ruby
module TranslatesWithAccessors

  def translates(*params)
    options = params.dup.extract_options!
    options.reverse_merge!(:globalize_accessors => true)
    accessors = options.delete(:globalize_accessors)
    super
    globalize_accessors if accessors
  end

end
````

## Licence

Copyright (c) 2009-2013 Tomek "Tomash" Stachewicz (http://tomash.wrug.eu),
Robert Pankowecki (http://robert.pankowecki.pl), Chris Salzberg (http://dejimata.com)
released under the MIT license
