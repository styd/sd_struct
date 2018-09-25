require_relative 'spec_helper'

puts "\n\e[33mDeep Initialization\e[0m\n"

Benchmark.ips do |x|
  x.report 'hashugar' do
    Hashugar.new({a: {b: "ab"}})
  end

  x.report 'hashie/mash' do
    Hashie::Mash.new({a: {b: "ab"}})
  end

  x.report 'hashr' do
    Hashr.new({a: {b: "ab"}})
  end

  x.report 'sd_struct' do
    SdStruct.new({a: {b: "ab"}})
  end

  x.compare!
end
