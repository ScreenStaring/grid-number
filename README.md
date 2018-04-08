# GRid

[![Build Status](https://secure.travis-ci.org/ScreenStaring/grid_number.svg)](https://secure.travis-ci.org/ScreenStaring/grid_number)

Class for managing Global Release Identifiers (GRid numbers).
GRid numbers are used to identify electronic music releases.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "grid_number"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grid_number

## Usage

```rb
require "grid"

grid = GRid.parse("A12425GABC1234011K")
grid = GRid.parse("A1-2425G-ABC1234011-K")
grid = GRid.parse("  grid:A1-2425G-ABC1234011-K  ")
grid.valid?          # true
grid.id_scheme       # A1
grid.issuer_code     # 2425G
grid.release_number  # ABC1234011
grid.check_character # K

grid = GRid.new(:issuer_code => "2425G", :release_number => "ABC1234002")
grid.check_character # M
grid.release_number = "X999150000"
grid.check_character # 3

grid = GRid.parse("A12425GABC1234011X") # Wrong check character
grid.valid?                   # false
grid.errors[:check_character] # ["verification failed"]

GRid.default_issuer_code = "2425G"
grid = GRid.new(:release_number => "ABC1234002")
grid.to_s           # A12425GABC1234002M
grid.formatted      # A1-2425G-ABC1234002-M
```

## Links

* [Global Release Identifier](https://en.wikipedia.org/wiki/Global_Release_Identifier)
* [Documentation](http://rdoc.info/gems/grid_number)
* [Homepage](https://github.com/ScreenStaring)

## See Also

* [DDEX](https://github.com/sshaw) - DDEX metadata serialization
* [istwox](https://github.com/malenkiki/istwox) - Classes for ISBN, ISSN, ISRC, ISMN and ISAN numbers
* [iTunes Store Transporter: GUI](http://transportergui.com) - GUI and workflow automation for the iTunes Store’s Transporter (`iTMSTransporter`)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

---

Made by [ScreenStaring](http://screenstaring.com)
