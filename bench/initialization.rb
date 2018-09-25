require_relative 'spec_helper'

puts "\n\e[33mInitialization\e[0m\n"

Benchmark.ips do |x|
  x.report 'ostruct' do
    OpenStruct.new({a: "string"})
  end

  x.report 'finer_struct/mutable' do
    FinerStruct::Mutable.new({a: "string"})
  end

  x.report 'finer_struct/immutable' do
    FinerStruct::Immutable.new({a: "string"})
  end

  x.report 'hashugar' do
    Hashugar.new({a: "string"})
  end

  x.report 'hashie/mash' do
    Hashie::Mash.new({a: "string"})
  end

  x.report 'hashr' do
    Hashr.new({a: "string"})
  end

  x.report 'sd_struct' do
    SdStruct.new({a: "string"})
  end

  x.compare!
end
