require_relative 'spec_helper'
require 'json'

puts "\n\e[33mDeep #to_json\e[0m\n"

mstruct = Hashie::Mash.new({"a" => {b: "b"}})
puts "Hashie::Mash: #{mstruct.to_json}"
hrstruct = Hashr.new({"a" => {b: "b"}})
puts "Hashr: #{hrstruct.to_json}"
hsstruct = Hashugar.new({"a" => {b: "b"}})
puts "Hashugar: #{hsstruct.to_json}"
sdstruct = SdStruct.new({"a" => {b: "b"}})
puts "SdStruct: #{sdstruct.to_json}"

Benchmark.ips do |x|
  x.report 'hashie/mash' do
    mstruct.to_json
  end

  x.report 'sd_struct' do
    sdstruct.to_json
  end

  x.compare!
end
