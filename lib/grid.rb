class GRid
  VERSION = "0.0.1".freeze

  DEFAULT_ID_SCHEME = "A1".freeze
  CHECK_CODES  = (("0".."9").to_a + ("A".."Z").to_a).freeze

  attr_reader :id_scheme, :issuer_code, :release_number, :errors, :check_character

  class << self
    #
    # The issuer code to use when instansating an instance and none is provided.
    #
    def default_issuer_code
      @default_issuer_code
    end

    def default_issuer_code=(code)
      @default_issuer_code = code
    end

    #
    # Create an instance from +str+.
    #
    #  grid = GRid.parse("A12425GABC1234002")
    #  grid = GRid.parse("A1-2425G-ABC1234002-M")
    #  grid = GRid.parse("grid:A1-2425G-ABC1234002-M")
    #
    # === Arguments
    #
    # [str (String)] The GRid to parse, does not have to be valid
    #
    # === Returns
    #
    # An instance of GRid representing +str+.
    #
    # === Errors
    #
    # No errors are raised. A GRid is always returned.
    # To determine if it's valid call its #valid? method.
    #
    def parse(str)
      return GRid.new if str.nil?

      str = str.strip
      return GRid.new if str.empty?

      str.upcase!
      str.sub!(/\AGRID:/, "")

      extract = lambda do |i, j|
        val = str[i, j]
        return unless val

        # 2.5 has delete_prefix
        str[i, j] = ""
        str.sub!(/\A-/, "")

        val
      end

      GRid.new(:id_scheme => extract[0, 2],
               :issuer_code => extract[0, 5],
               :release_number => extract[0, 10],
               :check_character => extract[-1, 1])
    end
  end

  #
  # Create a new instance consisting of +parts+.
  # The #check_character will be calculated if none is given.
  #
  # === Arguments
  #
  # [parts (Hash)] Parts of the GRid, optional
  #
  # === Parts
  #
  # All parts are optional.
  #
  # [:id_scheme (String)] ID scheme portion, defaults to +A1+
  # [:issuer_code (String)] Issuer code portion, defaults to default_issuer_code
  # [:release_number (String)] Release number portion
  # [:check_character (String)] Check character portion, will be calculated if not given
  #

  def initialize(parts = nil)
    parts ||= {}

    @issuer_code = parts[:issuer_code]
    @issuer_code = self.class.default_issuer_code.dup if @issuer_code.nil? && self.class.default_issuer_code
    @release_number = parts[:release_number]
    @id_scheme = parts[:id_scheme] || DEFAULT_ID_SCHEME.dup
    @check_character = parts[:check_character] || calculate_check_character

    @errors = {}
  end

  %w[id_scheme issuer_code release_number].each do |name|
    class_eval <<-METHOD, __FILE__, __LINE__ + 1
      def #{name}=(s)
        @#{name} = s
        recalculate_check_character!
        @#{name}
      end
    METHOD
  end

  #
  # Validate the GRid. To get the errors call #errors.
  #
  #  if !grid.valid?
  #    grid.errors.each do |attr, errors|
  #      printf "%10s: %s", attr, errors.join(", ")
  #    end
  #  end
  #
  def valid?
    errors.clear

    validate_id_scheme!
    validate_issuer_code!
    validate_release_number!
    validate_check_character!

    errors.empty?
  end

  def recalculate_check_character!
    @check_character = calculate_check_character
    nil
  end

  #
  # Create a Hash representing the GRid. Keys are Symbols representing the portions of the GRid.
  #
  def to_h
    { :id_scheme => id_scheme,
      :issuer_code => issuer_code,
      :release_number => release_number,
      :check_character => check_character }
  end

  #
  # Return a formatted +String+ representation of the GRid.
  #
  def formatted
    [ id_scheme, issuer_code, release_number, check_character ].compact.join("-").upcase
  end

  def to_s
    [ id_scheme, issuer_code, release_number, check_character ].compact.join("").upcase
  end

  def ==(other)
    other = self.class.parse(other) if other.is_a?(String)
    eql?(other)
  end

  def eql?(other)
    other.instance_of?(self.class) && to_s == other.to_s
  end

  def hash
    to_s.hash
  end

  private

  def validate_id_scheme!
    if id_scheme != DEFAULT_ID_SCHEME
      errors[:id_scheme] = ["must be #{DEFAULT_ID_SCHEME}"]
    end
  end

  def validate_issuer_code!
    messages = []

    if issuer_code.nil?
      messages << "required"
    elsif issuer_code !~ /\A[a-z0-9]{5}\z/i
      messages << "must be 5 alphanumeric characters"
    end

    errors[:issuer_code] = messages if messages.any?
  end

  def validate_release_number!
    messages = []

    if release_number.nil?
      messages << "required"
    elsif release_number !~ /\A[a-z0-9]{10}\z/i
      messages << "must be 10 alphanumeric characters"
    end

    errors[:release_number] = messages if messages.any?
  end

  def validate_check_character!
    messages = []

    if check_character.nil?
      messages << "required"
    elsif check_character != calculate_check_character
      messages << "verification failed"
    end

    errors[:check_character] = messages if messages.any?
  end

  def calculate_check_character
    value = to_s[0, 17]
    char = 36

    0.upto(value.size - 1) do |lng|
      v = CHECK_CODES.index(value[lng])
      return unless v

      char += v
      char -= 36 if char > 36
      char *= 2
      char -= 37 if char >= 37
    end

    char = 37 - char
    char = 0 if char == 36

    CHECK_CODES[char]
  end
end
