require_relative 'spec_helper'
require 'json'

puts "\n\e[33mJSON#parse :object_class\e[0m\n"

json = "{\"object\":{\"a\":\"bau bau\",\"c\":\"boo boo\"},\"array\":[{\"one\":1,\"two\":2,\"three\":3}],\"two words\":\"Foo bar\"}"

puts "OpenStruct: #{JSON.parse(json, object_class: OpenStruct)}"
puts "Hashie::Mash: #{JSON.parse(json, object_class: Hashie::Mash)}"
puts "SdStruct: #{JSON.parse(json, object_class: SdStruct)}"

Benchmark.ips do |x|
  x.report 'ostruct' do
    JSON.parse(json, object_class: OpenStruct)
  end

  x.report 'hashie/mash' do
    JSON.parse(json, object_class: Hashie::Mash)
  end

  x.report 'sd_struct' do
    JSON.parse(json, object_class: SdStruct)
  end

  x.compare!
end
