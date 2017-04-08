require "sd_struct/version"

class SDStruct
  using Module.new {
    refine Hash do
      def to_struct
        SDStruct.new(to_h.dup)
      end
    end

    refine Array do
      alias :original_to_h :to_h

      def to_h(camelize_keys = false)
        map{|x| x.respond_to?(:to_h) ? x.to_h(camelize_keys) : x }
      end

      def to_struct
        map{|x| ( x.is_a?(Hash) || x.is_a?(Array) ) ? x.to_struct : x }
      end

      def dig_deep(*args)
        full_args = args.dup
        parent_key = args.shift
        result = nil
        if parent_key.is_a?(Integer)
          result = dig(parent_key)
          unless result.nil? || args.length.zero?
            result = result.dig_deep(*args)
          end
        end
        if result.nil?
          each do |x|
            if x.respond_to?(:dig_deep) || x.is_a?(Array)
              result = x.dig_deep(*full_args)
            end
            return result unless result.nil?
          end
        end
        return result
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

  def to_h(opt = {})
    opt = {
      camelize_keys: false,
      exclude_blank_values: false,
      exclude_values: []
    }.merge(opt)

    @table.map do |k, v|
      v = v.to_h(opt) if v.is_a?(self.class) || v.is_a?(Array)
      k = k.to_s.camelize(:lower) if opt[:camelize_keys] && !k[/\s+/]
      [k, v]
    end.original_to_h
       .select{|_,v| opt[:exclude_blank_values] ? v.present? : !v.nil? }
       .select{|_,v| !v.in?(opt[:exclude_values]) }
  end

  def to_json(opt = {})
    opt = {
      camelize_keys: true,
      exclude_blank_values: true,
      exclude_values: [0, [""], [{}]]
    }.merge(opt)

    to_h(opt).to_json
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

  def dig_deep(*args)
    full_args = args.dup
    parent_key = args.shift
    result = dig(parent_key)
    unless result.nil? || args.length.zero?
      if result.respond_to?(:dig)
        result = result.dig(*args)
      end
    end
    if result.nil?
      @table.values
            .select{|v| v.respond_to?(:dig) }
            .each do |v|
              if v.respond_to?(:dig_deep) || v.is_a?(Array)
                result = v.dig_deep(*full_args)
              end
              return result unless result.nil?
            end
    end
    return result
  end

  def dig(*args)
    @table.dig(*args)
  end

  def find(key_str, opt = {})
    opt = {
      delimiter: "/"
    }.merge(opt)

    args = key_str.split(opt[:delimiter])
                  .map do |x|
                    x.strip!
                    if !!(x =~ /\A[-+]?\d+\z/)
                      x.to_i
                    else
                      if x[/\s+/]
                        x
                      else
                        x.underscore.to_sym
                      end
                    end
                  end

    result = dig_deep(*args) rescue nil
    return result
  end

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
