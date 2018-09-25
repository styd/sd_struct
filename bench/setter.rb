require_relative 'spec_helper'

puts "\n\e[33mSetter\e[0m\n"

ostruct = OpenStruct.new({a: "string"})
mstruct = Hashie::Mash.new({a: "string"})
hrstruct = Hashr.new({a: "string"})
hsstruct = Hashugar.new({a: "string"})
sdstruct = SdStruct.new({a: "string"})

Benchmark.ips do |x|
  x.report 'ostruct' do
    ostruct.c = "c"
  end

  x.report 'hashie/mash' do
    mstruct.c = "c"
  end

  x.report 'hashr' do
    hrstruct.c = "c"
  end

  x.report 'hashugar' do
    hsstruct.c = "c"
  end

  x.report 'sd_struct' do
    sdstruct.c = "c"
  end

  x.compare!
end
