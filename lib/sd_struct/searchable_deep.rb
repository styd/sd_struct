module SearchableDeep
  refine Array do
    def to_h
      map(&:to_h)
    end

    #
    # Digs deep into array until non-Array and non-Hash primitive data is found
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

    def respond_to?(m_id)
      [:dig_deep, :to_sd_struct].include?(m_id) || super
    end
  end
end
