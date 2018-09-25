require_relative 'spec_helper'

puts "\n\e[33m#to_h\e[0m\n"

hash = {"a" => "a", b: "b"}
puts "Original Hash: #{hash}"
ostruct = OpenStruct.new(hash)
puts "OpenStruct: #{ostruct.to_h}"
mstruct = Hashie::Mash.new(hash)
puts "Hashie::Mash: #{mstruct.to_h}"
hrstruct = Hashr.new(hash)
puts "Hashr: #{hrstruct.to_h}"
hsstruct = Hashugar.new(hash)
puts "Hashugar: #{hsstruct.to_hash}"
sdstruct = SdStruct.new(hash)
puts "SdStruct: #{sdstruct.to_h}"

Benchmark.ips do |x|
  x.report 'ostruct' do
    ostruct.to_h
  end

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
