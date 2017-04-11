class SDStruct
  using Module.new {
    refine Array do
      alias :original_to_h :to_h

      def to_h(camelize_keys = false)
        map{|x| x.respond_to?(:to_h) ? x.to_h(camelize_keys) : x }
      end
    end
  }

  def to_h(opts = {})
    opts = {
      camelize_keys: false,
      exclude_blank_values: false,
      values_to_exclude: []
    }.merge(opts)

    @table.map do |k, v|
      v = v.to_h(opts) if v.is_a?(self.class) || v.is_a?(Array)
      k = k.to_s.camelize(:lower) if opts[:camelize_keys] && !k[/\s+/]
      [k, v]
    end.original_to_h
       .select{|_,v| opts[:exclude_blank_values] ? v.present? : !v.nil? }
       .select{|_,v| !v.in?(opts[:values_to_exclude]) }
  end

  def to_json(opts = {})
    opts = {
      camelize_keys: true,
      exclude_blank_values: true,
      values_to_exclude: [0, [""], [{}]]
    }.merge(opts)

    to_h(opts).to_json
  end
end
