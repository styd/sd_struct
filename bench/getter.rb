require_relative 'spec_helper'

puts "\n\e[33mGetter\e[0m\n"

ostruct = OpenStruct.new({a: {b: "ab"}})
mstruct = Hashie::Mash.new({a: {b: "ab"}})
hrstruct = Hashr.new({a: {b: "ab"}})
hsstruct = Hashugar.new({a: {b: "ab"}})
sdstruct = SdStruct.new({a: {b: "ab"}})

Benchmark.ips do |x|
  x.report 'ostruct' do
    ostruct.a
  end

  x.report 'hashie/mash' do
    mstruct.a
  end

  x.report 'hashr' do
    hrstruct.a
  end

  x.report 'hashugar' do
    hsstruct.a
  end

  x.report 'sd_struct' do
    sdstruct.a
  end

  x.compare!
end
