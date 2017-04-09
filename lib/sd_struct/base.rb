# Alternative to OpenStruct that is more strict and go deeper.
#
# @author Adrian Setyadi
#
class SDStruct
  using Module.new {
    refine Hash do
      def to_struct
        SDStruct.new(to_h.dup)
      end
    end

    refine Array do
      # Call `to_struct` to an Array to go deeper or to a Hash to change it to SDStruct
      #
      # @return [Array<SDStruct,Object>] array of SDStruct or any other objects
      #
      def to_struct
        map{|x| ( x.is_a?(Hash) || x.is_a?(Array) ) ? x.to_struct : x }
      end
    end
  }

  def initialize(hash = nil, deep = true)
    @table = {}
    if hash
      hash.each_pair do |k, v|
        v = v.to_struct if deep && ( v.is_a?(Hash) || v.is_a?(Array) )
        @table[new_member(k)] = v
      end
    end
  end

  def initialize_copy(orig)
    super
    @table = @table.dup
  end

  def marshal_dump
    to_h
  end

  def marshal_load(x)
    @table = x.map{|a| ( a.is_a?(Hash) || a.is_a?(Array) ) ? a.to_struct : a }
              .original_to_h
  end

  def new_member(name)
    name = name.to_s.underscore.to_sym unless name[/\s+/] # contains whitespace
    unless respond_to?(name)
      define_singleton_method(name) { @table[name] }
      define_singleton_method("#{name}=") { |x| @table[name] = x }
    end
    name
  end
  protected :new_member

  def [](name)
    @table.has_key?(name) ? @table[name] : @table[name.to_s.underscore.to_sym]
  end

  def []=(name, value)
    @table[new_member(name)] = value
  end

  InspectKey = :__inspect_key__ # :nodoc:

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

  def eql?(other)
    return false unless other.kind_of?(self.class)
    @table.eql?(other.table)
  end

  def hash
    @table.hash
  end

  def spaced_keys
    @table.keys - non_spaced_keys
  end

  def non_spaced_keys
    methods(false).select{|x| x[/^\S+[^=]$/]}
  end
  alias :fields :non_spaced_keys

  def keys
    @table.keys
  end

  def delete_field(name)
    sym = name.to_sym
    @table.delete(sym) do
      raise NameError.new("no field `#{sym}' in #{self}", sym)
    end
    singleton_class.__send__(:remove_method, sym, "#{sym}=")
  end
  alias :delete_key :delete_field
end
