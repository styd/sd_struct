require_relative 'spec_helper'

puts "\n\e[33mSdStruct Getters\e[0m\n"

struct = SdStruct.new({a: {b: {c: "abc"}}})

Benchmark.ips do |x|
  x.report 'method chain' do
    struct.a.b.c
  end

  x.report 'xpath absolute' do
    struct.find('a/b/c')
  end

  x.report 'xpath relative' do
    struct.find('//c')
  end

  x.compare!
end
