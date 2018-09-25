require_relative 'spec_helper'

puts "\n\e[33mDeep Getter\e[0m\n"

mstruct = Hashie::Mash.new({a: {b: "ab"}})
hrstruct = Hashr.new({a: {b: "ab"}})
hsstruct = Hashugar.new({a: {b: "ab"}})
sdstruct = SdStruct.new({a: {b: "ab"}})

Benchmark.ips do |x|
  x.report 'hashie/mash' do
    mstruct.a.b
  end

  x.report 'hashr' do
    hrstruct.a.b
  end

  x.report 'hashugar' do
    hsstruct.a.b
  end

  x.report 'sd_struct' do
    sdstruct.a.b
  end

  x.compare!
end
