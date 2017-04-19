class SDStruct
  using Module.new {
    refine Array do

      #
      # Dig deep into array until non-Array and non-Hash primitive data is found
      #
      # @param [Symbol] multiple symbols
      # @return [String,Integer,Float,Boolean,nil] first matched result
      #
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

  #
  # Dig deep into Hash until non-Array and non-Hash primitive data is found
  #
  # @param [Symbol] multiple symbols
  # @return [SDStruct,Hash,Array,String,Integer,Float,Boolean,nil] first matched result
  #
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

  #
  # Dig the content of @table which is a hash
  #
  # @param [Symbol] multiple symbols
  # @return [SDStruct,Hash,Array,String,Integer,Float,Boolean,nil] first matched result
  #
  def dig(*args)
    @table.dig(*args)
  end

  def find(key_str, opts = {})
    opts = {
      separator: "/"
    }.merge(opts)

    sep = Regexp.quote(opts[:separator])

    args = begin
      key_str.gsub(/^#{sep}(?!#{sep})|#{sep}+$/, '')
             .split(/#{sep}{2,}/)
             .map do |ks|
               ks.split(/#{sep}/)
                 .map do |x|
                   x.strip!
                   if !!x[/\A[-+]?\d+\z/]
                     x.to_i
                   else
                     if x[/^$|\s+/]
                       x
                     else
                       x.underscore.to_sym
                     end
                   end
                 end
             end
    end

    if !(parent_key = args.shift) # args == [], key_str == ""
      return
    else # e.g. args == [[], ..] or [[.., ..], [..]]
      result = dig(*parent_key) unless parent_key.empty?

      unless args.length.zero?
        args.each do |a|
          result = result.dig_deep(*a) rescue result = dig_deep(*a)
        end
      end
    end
    return result
  end
end
