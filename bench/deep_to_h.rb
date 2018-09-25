require_relative 'spec_helper'

puts "\n\e[33mDeep #to_h\e[0m\n"

mstruct = Hashie::Mash.new({"a" => {b: "b"}})
puts "Hashie::Mash: #{mstruct.to_h}"
hrstruct = Hashr.new({"a" => {b: "b"}})
puts "Hashr: #{hrstruct.to_h}"
hsstruct = Hashugar.new({"a" => {b: "b"}})
puts "Hashugar: #{hsstruct.to_hash}"
sdstruct = SdStruct.new({"a" => {b: "b"}})
puts "SdStruct: #{sdstruct.to_h}"

Benchmark.ips do |x|
  x.report 'hashie/mash' do
    mstruct.to_h
  end

  x.report 'hashr' do
    hrstruct.to_h
  end

  x.report 'hashugar' do
    hsstruct.to_hash
  end

  x.report 'sd_struct' do
    sdstruct.to_h
  end

  x.compare!
end
