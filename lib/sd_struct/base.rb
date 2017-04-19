# Alternative to OpenStruct that is more strict and go deeper.
#
# @author Adrian Setyadi
#
class SDStruct
  using Module.new {
    refine Hash do
      #
      # Changes current Hash object to SDStruct object
      #
      # @return [SDStruct] SDStruct object
      #
      def to_struct
        SDStruct.new(to_h.dup)
      end
    end

    refine Array do

      #
      # Calls `to_struct` to an Array to go deeper or to a Hash to change it to SDStruct
      #
      # @return [Array<SDStruct,Object>] array of SDStruct or any other objects
      #
      def to_struct
        map{|x| ( x.is_a?(Hash) || x.is_a?(Array) ) ? x.to_struct : x }
      end
    end
  }

  #
  # Creates a new SDStruct object. By default, the resulting SDStruct object
  # will have no attributes.
  #
  # The optional +hash+, if given, will generate attributes and values (can be
  # a Hash, an SDStruct or a Struct).
  # For example:
  #
  #   require 'sd_struct' # or require 'sd_struct/base'
  #   hash = { "name" => "Matz", "coding language" => :ruby, :age => "old" }
  #   data = SDStruct.new(hash)
  #
  #   p data # -> #<SDStruct .name="Matz", ['coding language']=:ruby, .age="old">
  #
  def initialize(hash = nil, deep = true)
    @deep = deep
    @table = {}
    if hash
      hash.each_pair do |k, v|
        @table[new_struct_member(k)] = structurize(v) # @deep is used in this method
      end
    end
  end

  #
  # Duplicates an SDStruct object members.
  #
  def initialize_copy(orig)
    super
    @table = @table.dup
  end

  #
  # Provides marshalling support for use by the Marshal library.
  #
  def marshal_dump
    to_h
  end

  #
  # Provides marshalling support for use by the Marshal library.
  #
  def marshal_load(x)
    @table = x.map{|a| structurize(a) }.original_to_h
  end

  #
  # Yields all attributes (as a symbol) along with the corresponding values
  # or returns an enumerator if not block is given.
  # Example:
  #
  #   require 'sd_struct'
  #   data = SDStruct.new("name" => "Matz", "coding language" => :ruby)
  #   data.each_pair.to_a  # => [[:name, "Matz"], ["coding language", :ruby]]
  #
  def each_pair
    return to_enum(__method__) { @table.size } unless block_given?
    @table.each_pair{|p| yield p}
  end

  #
  # Used internally to define field properties
  #
  def new_struct_member(name)
    name = name.to_s.underscore.to_sym unless name[/^[A-Z]|\s+/]
    unless respond_to?(name)
      define_singleton_method(name) { @table[name] }
      define_singleton_method("#{name}=") { |x| @table[name] = x }
    end
    name
  end

  #
  # Calls to struct to a value if it is an Array or a Hash and @deep is true
  #
  def structurize(value)
    ( @deep && (value.is_a?(Hash) || value.is_a?(Array)) ) ? value.to_struct : value
  end

  protected :new_struct_member, :structurize


  #
  # Returns the value of a member.
  #
  #   person = SDStruct.new('name' => 'Matz', 'lang' => 'ruby')
  #   person[:lang] # => ruby, same as person.lang
  #
  def [](name)
    @table.has_key?(name) ? @table[name] : @table[name.to_s.underscore.to_sym]
  end

  #
  # Sets the value of a member.
  #
  #   person = SDStruct.new('name' => 'Matz', 'lang' => 'python')
  #   person[:lang] = 'ruby' # => equivalent to person.lang = 'ruby'
  #   person.lang # => ruby
  #
  def []=(name, value)
    unless self[name].nil? || value.is_a?(self[name].class)
      warn("You're assigning a value with different type as the previous value.")
    end
    @table[new_struct_member(name)] = structurize(value)
  end

  InspectKey = :__inspect_key__ # :nodoc:

  #
  # Returns a string containing a detailed summary of the keys and values.
  #
  def inspect
    str = "#<#{self.class}"

    ids = (Thread.current[InspectKey] ||= [])
    if ids.include?(object_id)
      return str << ' ...>'
    end

    ids << object_id
    begin
      first = true
      for k,v in @table
        str << "," unless first
        first = false
        str << " #{k[/\s+/] ? "['#{k}']" : ".#{k}"}=#{v.inspect}"
      end
      return str << '>'
    ensure
      ids.pop
    end
  end
  alias :to_s :inspect

  attr_reader :table
  protected :table

  def ==(other)
    return false unless other.kind_of?(self.class)
    @table == other.table
  end

  #
  # Compares this object and +other+ for equality.  An SDStruct is eql? to
  # +other+ when +other+ is an SDStruct and the two objects' Hash tables are
  # eql?.
  #
  def eql?(other)
    return false unless other.kind_of?(self.class)
    @table.eql?(other.table)
  end

  #
  # Computes a hash-code for this SDStruct.
  # Two hashes with the same content will have the same hash code
  # (and will be eql?).
  #
  def hash
    @table.hash
  end

  #
  # Exposes keys with space(s)
  #
  def spaced_keys
    @table.keys - non_spaced_keys
  end

  #
  # Exposes keys without space(s)
  #
  def non_spaced_keys
    methods(false).select{|x| x[/^\S+[^=]$/]}
  end
  alias :fields :non_spaced_keys

  #
  # Exposes all keys
  #
  def keys
    @table.keys
  end

  #
  # Deletes specified field or key
  #
  def delete_field(name)
    sym = name.to_sym
    @table.delete(sym) do
      raise NameError.new("no field `#{sym}' in #{self}", sym)
    end
    singleton_class.__send__(:remove_method, sym, "#{sym}=")
  end
  alias :delete_key :delete_field
end
