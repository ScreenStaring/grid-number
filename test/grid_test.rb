require "test_helper"

class GRidTest < Minitest::Test
  def setup
    @id_scheme = "A1"
    @issuer_code = "2425G"
    @release_number = "ABC1234002"
    @check_character = "M"
  end

  def test_valid
    grid = GRid.new
    refute grid.valid?

    grid = GRid.new(:issuer_code => @issuer_code, :release_number => @release_number, :check_character => @check_character)
    assert grid.valid?

    grid = GRid.new(:issuer_code => @issuer_code, :release_number => @release_number, :check_character => "Q")
    refute grid.valid?
  end

  def test_errors_empty_unless_invalid
    grid = GRid.new(:issuer_code => @issuer_code, :release_number => @release_number, :check_character => @check_character)
    assert grid.errors.empty?

    grid.release_number = nil
    grid.valid?
    refute grid.errors.empty?
  end

  def test_check_character_errors
    grid = GRid.new(:issuer_code => @issuer_code, :release_number => @release_number, :check_character => "Q")

    grid.valid?
    assert_equal ["verification failed"], grid.errors[:check_character]
  end

  def test_check_issuer_code_errors
    grid = GRid.new(:issuer_code => "X")

    grid.valid?
    assert_equal ["must be 5 alphanumeric characters"], grid.errors[:issuer_code]

    grid.issuer_code = nil
    grid.valid?
    assert_equal %w[required], grid.errors[:issuer_code]
  end

  def test_release_number_errors
    grid = GRid.new(:release_number => "X")

    grid.valid?
    assert_equal ["must be 10 alphanumeric characters"], grid.errors[:release_number]

    grid.release_number = nil
    grid.valid?
    assert_equal %w[required], grid.errors[:release_number]
  end

  def test_id_scheme_errors
    grid = GRid.new(:id_scheme => "X")

    grid.valid?
    assert_equal ["must be A1"], grid.errors[:id_scheme]

    grid.id_scheme = nil
    grid.valid?
    assert_equal ["must be A1"], grid.errors[:id_scheme]
  end

  def test_recalculate_check_character!
    grid = GRid.new(:issuer_code => @issuer_code, :release_number => @release_number, :check_character => "Q")
    grid.recalculate_check_character!
    assert_equal @check_character, grid.check_character
  end

  def test_check_character_digit_calculated_on_initialize
    grid = GRid.new(:issuer_code => @issuer_code, :release_number => @release_number)
    assert_equal @check_character, grid.check_character
  end

  def test_check_character_digit_calculated_on_release_number_assignment
    grid = GRid.new(:issuer_code => @issuer_code)
    grid.release_number = @release_number
    assert_equal @check_character, grid.check_character
  end

  def test_check_character_digit_calculated_on_issuer_code_assignment
    grid = GRid.new(:release_number => @release_number)
    grid.issuer_code = @issuer_code
    assert_equal @check_character, grid.check_character
  end

  def test_check_character_digit_calculated_on_id_scheme_assignment
    grid = GRid.new(:id_scheme => "QQ", :release_number => @release_number, :issuer_code => @issuer_code)
    grid.id_scheme = @id_scheme
    assert_equal @check_character, grid.check_character
  end

  def test_default_id_scheme_used
    grid = GRid.new
    assert_equal GRid::DEFAULT_ID_SCHEME, grid.id_scheme

    grid = GRid.new(:id_scheme => "XX", :issuer_code => @issuer_code, :release_number => @release_number)
    assert_equal "XX", grid.id_scheme
  end

  def test_default_issuer_code
    GRid.default_issuer_code = "ABCDE"

    grid = GRid.new
    assert_equal "ABCDE", grid.issuer_code

    grid = GRid.new(:issuer_code => "QQ", :release_number => @release_number)
    assert_equal "QQ", grid.issuer_code
  end

  def test_eql
    grid1 = GRid.new(:issuer_code => @issuer_code, :release_number => @release_number)
    grid2 = GRid.new(:issuer_code => @issuer_code.dup, :release_number => @release_number.dup)

    assert grid1.eql?(grid2)
    refute grid1.eql?(grid1.to_s)

    grid2.release_number = "X"
    refute grid1.eql?(grid2)
  end

  def test_double_equal
    grid1 = GRid.new(:issuer_code => @issuer_code, :release_number => @release_number)
    grid2 = GRid.new(:issuer_code => @issuer_code.dup, :release_number => @release_number.dup)
    assert grid1 == grid2

    grid2.release_number = "X"
    refute grid1 == grid2
  end

  def test_double_equal_with_string
    grid1 = GRid.new(:issuer_code => @issuer_code, :release_number => @release_number)
    grid2 = GRid.new(:issuer_code => @issuer_code.dup, :release_number => @release_number.dup)
    assert grid1 == grid2.to_s

    grid2.release_number = "X"
    refute grid1 == grid2.to_s
  end

  def test_hash
    grid = GRid.new(:issuer_code => @issuer_code, :release_number => @release_number)
    assert_equal grid.to_s.hash, grid.hash
  end

  def test_to_h
    expect = { :id_scheme => "X", :issuer_code => "A", :release_number => "B", :check_character => "C" }
    grid = GRid.new(expect)
    assert_equal expect, grid.to_h
  end

  def test_formatted
    expect = "#@id_scheme-#@issuer_code-#@release_number-#@check_character"
    grid = GRid.new(:issuer_code => @issuer_code, :release_number => @release_number, :check_character => @check_character)
    assert_equal expect, grid.formatted
  end

  def test_to_s
    expect = "#@id_scheme#@issuer_code#@release_number#@check_character"
    grid = GRid.new(:issuer_code => @issuer_code, :release_number => @release_number, :check_character => @check_character)
    assert_equal expect, grid.to_s
  end

  def to_s_upcases
    expect = "#@id_scheme#@issuer_code#@release_number#@check_character"
    grid = GRid.new(:issuer_code => @issuer_code.downcase, :release_number => @release_number.downcase, :check_character => @check_character.downcase)
    assert_equal expect, grid.to_s
  end

  def test_parse_invalid_format
    ["", nil, "BAD", "!-"].each do |s|
      grid = GRid.parse(s)
      assert_equal false, grid.valid?
    end
  end

  def test_parse_valid_formats
    ["grid:#@id_scheme#@issuer_code#@release_number#@check_character",
     "grid:#@id_scheme-#@issuer_code-#@release_number-#@check_character",
     "GRiD:#@id_scheme#@issuer_code-#@release_number-#@check_character",
     "#@id_scheme-#@issuer_code#@release_number-#@check_character",
     "#@id_scheme #@issuer_code #@release_number #@check_character",
     "#@id_scheme-#@issuer_code-#@release_number-#@check_character".downcase].each do |s|

      grid = GRid.parse(s)

      assert_equal true, grid.valid?
      assert_equal @id_scheme, grid.id_scheme
      assert_equal @issuer_code, grid.issuer_code
      assert_equal @release_number, grid.release_number
      assert_equal @check_character, grid.check_character
    end
  end
end
