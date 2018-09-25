require "sd_struct/searchable_deep"

# Another alternative to OpenStruct that is searchable and goes deeper.
#
# @author Adrian Setyadi
#
class SdStruct
  VERSION = "0.2.0"

  using SearchableDeep

  #
  # Creates a new SdStruct object. By default, the resulting SdStruct object
  # will have no attributes.
  #
  # The optional +hash+, if given, will generate attributes and values (can be
  # a Hash, an SdStruct or a Struct).
  # For example:
  #
  #   hash = { "name" => "Matz", "coding language" => :ruby, :country => "Japan" }
  #   data = SdStruct.new(hash)
  #
  #   p data # -> #<SdStruct name="Matz", coding language=:ruby, country="Japan">
  #
  def initialize(hash = {}, opts = {})
    hash = hash.dup
    @original_table = hash
    @table = {}
    hash.each_pair do |k, v|
      @table[k] = v.to_sd_struct
    end
  end

  def each_pair
    return to_enum(__method__) { @table.size } unless block_given?
    @table.each_pair{|p| yield p}
    self
  end

  def to_h
    hash = @original_table.to_h
    hash.each do |key, value|
      hash[key] = value.to_h if value.is_a?(SdStruct)
    end
  end
  alias to_hash to_h

  def to_json
    to_h.to_json
  end

  #
  # Used internally to define field properties
  #
  def new_sd_struct_member(name)
    name = name.to_sym
    unless singleton_class.method_defined?(name)
      define_singleton_method(name) { @table[name] }
      define_singleton_method("#{name}=") {|v| @original_table[name] = v; @table[name] = v.to_sd_struct }
    end
    name
  end

  def [](name)
    @table[name]
  end

  #
  # Sets the value of a member.
  #
  #   person = SdStruct.new('name' => 'Matz', 'lang' => 'python')
  #   person[:lang] = 'ruby' # => equivalent to person.lang = 'ruby'
  #   person.lang # => ruby
  #
  def []=(name, value)
    @table[new_sd_struct_member(name)] = value.to_sd_struct
  end

  #
  # Digs content
  #
  # @param [Symbol] multiple symbols
  # @return [SdStruct,Hash,Array,String,Integer,Float,Boolean,nil] first matched result
  #
  def dig(*args)
    @table.dig(*args)
  end

  #
  # Digs deep into Hash until non-Array and non-Hash primitive data is found
  #
  # @param [Symbol] multiple symbols
  # @return [SdStruct,Hash,Array,String,Integer,Float,Boolean,nil] first matched result
  #
  def dig_deep(*args)
    full_args = args.dup
    parent_key = args.shift
    result = @table.dig(parent_key)
    unless result.nil? || args.length.zero?
      if result.respond_to?(:dig)
        result = result.dig(*args)
      end
    end
    if result.nil?
      @table.values
            .select{|v| v.respond_to?(:dig) }
            .each do |v|
              if v.respond_to?(:dig_deep)
                result = v.dig_deep(*full_args)
              end
              return result unless result.nil?
            end
    end
    return result
  end

  #
  # Finds value with keys specified like xpath
  #
  # @param [String] key string
  # @param [Hash] option Hash
  # @return [SdStruct,Hash,Array,String,Integer,Float,Boolean,nil] first matched result
  #
  def find(key_str, separator: "/")
    sep = Regexp.quote(separator)

    args = begin
      key_str
        .gsub(/^#{sep}(?!#{sep})|#{sep}+$/, '')
        .split(/#{sep}{2,}/)
        .map do |ks|
          ks.split(/#{sep}/)
            .map do |x|
              x.strip!
              if !!x[/\A[-+]?\d+\z/]
                x.to_i
              else
                if x[/^$|^[A-Z]|\s+/]
                  x
                else
                  x.to_sym
                end
              end
            end
        end
    end

    if !(parent_key = args.shift) # args == [], key_str == ""
      return
    else # e.g. args == [[], ..] or [[.., ..], [..]]
      result = @table.dig(*parent_key) unless parent_key.empty?

      unless args.length.zero?
        args.each do |a|
          result = result.dig_deep(*a) rescue result = dig_deep(*a)
        end
      end
    end
    return result
  end

  #
  # Returns a string containing a detailed summary of the keys and values.
  #
  def inspect
    ids = (Thread.current[:__sd_struct__] ||= [])
    if ids.include?(object_id)
      detail = ' ...'
    else
      ids << object_id
      begin
        detail = @table.map do |key, value|
          " #{key}=#{value.inspect}"
        end.join(',')
      ensure
        ids.pop
      end
    end
    ['#<', self.class, detail, '>'].join
  end
  alias :to_s :inspect

  #
  # Compares this object and +other+ for equality.  An SdStruct is equal to
  # +other+ when +other+ is an SdStruct and the two objects' Hash tables are
  # equal.
  #
  #   first_pet  = SdStruct.new("name" => "Rowdy")
  #   second_pet = SdStruct.new(:name  => "Rowdy")
  #   third_pet  = SdStruct.new("name" => "Rowdy", :age => nil)
  #
  #   first_pet == second_pet   # => true
  #   first_pet == third_pet    # => false
  #
  def ==(other)
    return false unless other.is_a?(SdStruct)
    to_h == other.to_h
  end

  #
  # Compares this object and +other+ for equality.  An SdStruct is eql? to
  # +other+ when +other+ is an SdStruct and the two objects' Hash tables are
  # eql?.
  #
  def eql?(other)
    return false unless other.is_a?(SdStruct)
    @table.to_h.eql?(other.to_h)
  end

  def respond_to?(key, include_all=false)
    key = key.to_s.chomp('=').to_sym
    super(key) || @table.has_key?(key)
  end

  def method_missing(m_id, *args)
    len = args.length
    if m_name = m_id[/.*(?==\z)/m]
      if len != 1
        raise ArgumentError, "wrong number of arguments (#{len} for 1)", caller(1)
      end
      @original_table[m_name.to_sym] = args[0]
      @table[new_sd_struct_member(m_name)] = args[0].to_sd_struct
    elsif len.zero?
      if @table.key?(m_id)
        new_sd_struct_member(m_id)
        @table[m_id]
      end
    else
      begin
        super
      rescue NoMethodError => err
        err.backtrace.shift
        raise
      end
    end
  end
end

class Hash
  def to_sd_struct
    SdStruct.new(self)
  end
end

class Array
  def to_sd_struct
    map{|x| x.respond_to?(:to_sd_struct) ? x.to_sd_struct : x }
  end
end

class Object
  def to_sd_struct
    self
  end
end
