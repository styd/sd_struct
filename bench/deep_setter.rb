require_relative 'spec_helper'

puts "\n\e[33mDeep Setter\e[0m\n"

mstruct = Hashie::Mash.new({a: {b: "ab"}})
hrstruct = Hashr.new({a: {b: "ab"}})
hsstruct = Hashugar.new({a: {b: "ab"}})
sdstruct = SdStruct.new({a: {b: "ab"}})

Benchmark.ips do |x|
  x.report 'hashie/mash' do
    mstruct.c = {a: "string"}
  end

  x.report 'hashr' do
    hrstruct.c = {a: "string"}
  end

  x.report 'hashugar' do
    hsstruct.c = {a: "string"}
  end

  x.report 'sd_struct' do
    sdstruct.c = {a: "string"}
  end

  x.compare!
end
