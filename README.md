# SdStruct

Another alternative to OpenStruct that is searchable with xpath like syntax and
goes deeper in consuming the passed Hash and transforming it back to Hash or JSON.

## Usage

### From JSON

Example of a response body in JSON.

```JSON
"{\"object\":{\"a\":\"bau bau\",\"c\":\"boo boo\"},\"array\":[{\"one\":1,\"two\":2,\"three\":3}],\"two words\":\"Foo bar\"}"
```

> SdStruct inspects as OpenStruct would inspect.

```ruby
## with OpenStruct
ostruct = JSON.parse(json, object_class: OpenStruct)
# => #<OpenStruct object=#<OpenStruct a="bau bau", c="boo boo">,
# array=[#<OpenStruct one=1, two=2, three=3>], two words="Foo bar">

ostruct["two words"]
# => "Foo bar"

## with SdStruct
sd_struct = JSON.parse(json, object_class: SdStruct)
# => #<SdStruct object=#<SdStruct a="bau bau", c="boo boo">,
# array=[#<SdStruct one=1, two=2, three=3>], two words="Foo bar">

sd_struct["two words"]
# => "Foo bar"

# By the way, you can also use `send` method to access spaced key/field
o_struct.send("two words")
sd_struct.send("two words")
# => "Foo bar"
```


> OpenStruct's `to_h` doesn't return a hash deeply.

```ruby
## OpenStruct
o_struct.to_h
# => {:object=>#<OpenStruct a="bau bau", c="boo boo">,
# :array=>[#<OpenStruct one=1, two=2, three=3>], :"two words"=>"Foo bar"}

## SdStruct
sd_struct.to_h
# => {:object=>{:a=>"bau bau", :c=>"boo boo"},
# :array=>[{:one=>1, :two=>2, :three=>3}], "two words"=>"Foo bar"}
```


> OpenStruct doesn't have search or deep digging functionalities

```ruby
sd_struct.find('object/a')
# => "bau bau"

sd_struct.find('/array/0/one')
# => 1

sd_struct.find('object->a', separator: '->')
# => "bau bau"

# You can push it to find deeper. It will return the first occurrence of the matched field
sd_struct.find('.array..one', separator: '.')
# => 1

sd_struct.find('//a')
# => "bau bau"

sd_struct.find('//0/one')
# => 1

sd_struct.find('//one')
# => 1

sd_struct.find('//four')
# => nil

sd_struct.dig_deep(0, :one)
# => 1

sd_struct.dig_deep(:one)
# => 1
```


### From Hash

Example of a Hash.

```ruby
{
  :object => {
    :a => "bau bau",
    :c => "boo boo"
  },
  :array => [
    {
      :one => 1,
      :two => 2,
      :three => 3
    }
  ],
  "two words" => "Foo bar"
}
```


> OpensStruct doesn't consume a hash deeply

```ruby
## with OpenStruct
o_struct = OpenStruct.new(hash)
# => #<OpenStruct object={:a=>"bau bau", :c=>"boo boo"},
# array=[{:one=>1, :two=>2, :three=>3}], two words="Foo bar">

## with SdStruct
sd_struct = SdStruct.new(hash)
# => #<SdStruct .object=#<SdStruct .a="bau bau", .c="boo boo">,
# .array=[#<SdStruct .one=1, .two=2, .three=3>], ['two words']="Foo bar">
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activesupport

In your code:

```ruby
require 'active_support/all'
```


## Benchmark against OpenStruct and its other alternatives

### Initialization
```sh
$ ruby bench/initialization.rb

Initialization
Warming up --------------------------------------
             ostruct    23.719k i/100ms
finer_struct/mutable    21.343k i/100ms
finer_struct/immutable
                        20.148k i/100ms
            hashugar    17.404k i/100ms
         hashie/mash     8.790k i/100ms
               hashr     5.875k i/100ms
           sd_struct    13.516k i/100ms
Calculating -------------------------------------
             ostruct    355.611k (±15.1%) i/s -      1.731M in   5.045464s
finer_struct/mutable    285.687k (±15.2%) i/s -      1.387M in   5.020978s
finer_struct/immutable
                        311.364k (± 6.6%) i/s -      1.551M in   5.011959s
            hashugar    237.504k (± 2.7%) i/s -      1.201M in   5.060197s
         hashie/mash    110.607k (±17.4%) i/s -    527.400k in   5.003895s
               hashr     78.312k (± 9.7%) i/s -    387.750k in   5.004247s
           sd_struct    201.086k (±13.7%) i/s -    986.668k in   5.015946s

Comparison:
             ostruct:   355611.1 i/s
finer_struct/immutable:   311364.4 i/s - same-ish: difference falls within error
finer_struct/mutable:   285686.7 i/s - same-ish: difference falls within error
            hashugar:   237503.8 i/s - 1.50x  slower
           sd_struct:   201085.5 i/s - 1.77x  slower
         hashie/mash:   110606.6 i/s - 3.22x  slower
               hashr:    78311.9 i/s - 4.54x  slower
```

### Getter
```sh
$ ruby bench/getter.rb

Getter
Warming up --------------------------------------
             ostruct    62.616k i/100ms
         hashie/mash    32.544k i/100ms
               hashr    39.530k i/100ms
            hashugar    47.171k i/100ms
           sd_struct    64.453k i/100ms
Calculating -------------------------------------
             ostruct      3.807M (± 4.0%) i/s -     19.035M in   5.009086s
         hashie/mash    731.653k (± 4.2%) i/s -      3.677M in   5.035053s
               hashr      1.081M (± 3.3%) i/s -      5.416M in   5.014805s
            hashugar      1.631M (± 1.9%) i/s -      8.161M in   5.006753s
           sd_struct      3.969M (± 2.3%) i/s -     19.852M in   5.005272s

Comparison:
           sd_struct:  3968540.0 i/s
             ostruct:  3806506.9 i/s - same-ish: difference falls within error
            hashugar:  1630525.2 i/s - 2.43x  slower
               hashr:  1081108.5 i/s - 3.67x  slower
         hashie/mash:   731653.2 i/s - 5.42x  slower
```

### Setter
```sh
$ ruby bench/setter.rb

Setter
Warming up --------------------------------------
             ostruct    48.906k i/100ms
         hashie/mash    10.925k i/100ms
               hashr    26.087k i/100ms
            hashugar    37.424k i/100ms
           sd_struct    50.481k i/100ms
Calculating -------------------------------------
             ostruct      1.993M (± 5.5%) i/s -      9.977M in   5.022685s
         hashie/mash    149.320k (± 1.9%) i/s -    753.825k in   5.050346s
               hashr    475.269k (± 2.0%) i/s -      2.400M in   5.051718s
            hashugar      1.001M (± 3.2%) i/s -      5.015M in   5.015471s
           sd_struct      1.921M (± 4.8%) i/s -      9.591M in   5.005693s

Comparison:
             ostruct:  1992500.5 i/s
           sd_struct:  1921339.3 i/s - same-ish: difference falls within error
            hashugar:  1000912.9 i/s - 1.99x  slower
               hashr:   475268.8 i/s - 4.19x  slower
         hashie/mash:   149319.7 i/s - 13.34x  slower
```

### Deep Initialization
```sh
$ ruby bench/deep_initialization.rb

Deep Initialization
Warming up --------------------------------------
            hashugar    10.180k i/100ms
         hashie/mash     4.863k i/100ms
               hashr     3.111k i/100ms
           sd_struct     9.024k i/100ms
Calculating -------------------------------------
            hashugar    135.930k (± 2.5%) i/s -    682.060k in   5.021100s
         hashie/mash     57.260k (± 1.3%) i/s -    286.917k in   5.011621s
               hashr     36.165k (± 7.7%) i/s -    180.438k in   5.032553s
           sd_struct    111.588k (± 6.4%) i/s -    559.488k in   5.046688s

Comparison:
            hashugar:   135929.6 i/s
           sd_struct:   111588.5 i/s - 1.22x  slower
         hashie/mash:    57259.7 i/s - 2.37x  slower
               hashr:    36164.5 i/s - 3.76x  slower
```

### Deep Getter
```sh
$ ruby bench/deep_getter.rb

Deep Getter
Warming up --------------------------------------
         hashie/mash    21.798k i/100ms
               hashr    26.628k i/100ms
            hashugar    34.012k i/100ms
           sd_struct    53.437k i/100ms
Calculating -------------------------------------
         hashie/mash    394.113k (± 4.5%) i/s -      1.984M in   5.044513s
               hashr    551.904k (± 1.9%) i/s -      2.769M in   5.019679s
            hashugar    862.010k (± 1.4%) i/s -      4.320M in   5.011998s
           sd_struct      2.110M (± 8.6%) i/s -     10.420M in   5.016246s

Comparison:
           sd_struct:  2110253.6 i/s
            hashugar:   862010.3 i/s - 2.45x  slower
               hashr:   551903.9 i/s - 3.82x  slower
         hashie/mash:   394112.6 i/s - 5.35x  slower
```

### Deep Setter
```sh
$ ruby bench/deep_setter.rb

Deep Setter
Warming up --------------------------------------
         hashie/mash     5.145k i/100ms
               hashr     5.378k i/100ms
            hashugar    25.964k i/100ms
           sd_struct    13.419k i/100ms
Calculating -------------------------------------
         hashie/mash     61.130k (± 3.3%) i/s -    308.700k in   5.056208s
               hashr     62.056k (± 1.4%) i/s -    311.924k in   5.027385s
            hashugar    516.481k (± 1.9%) i/s -      2.596M in   5.028998s
           sd_struct    195.273k (± 2.1%) i/s -    979.587k in   5.018694s

Comparison:
            hashugar:   516480.7 i/s
           sd_struct:   195272.8 i/s - 2.64x  slower
               hashr:    62056.5 i/s - 8.32x  slower
         hashie/mash:    61130.5 i/s - 8.45x  slower
```

### \#to_h
```sh
$ ruby bench/to_h.rb

\#to_h
Original Hash: {"a"=>"a", :b=>"b"}
OpenStruct: {:a=>"a", :b=>"b"}
Hashie::Mash: {"a"=>"a", "b"=>"b"}
Hashr: {:a=>"a", :b=>"b"}
Hashugar: {"a"=>"a", :b=>"b"}
SdStruct: {"a"=>"a", :b=>"b"}
Warming up --------------------------------------
             ostruct    29.118k i/100ms
         hashie/mash    46.945k i/100ms
               hashr    10.818k i/100ms
            hashugar    49.588k i/100ms
           sd_struct    48.183k i/100ms
Calculating -------------------------------------
             ostruct    609.813k (± 2.4%) i/s -      3.057M in   5.016669s
         hashie/mash      1.378M (± 1.8%) i/s -      6.901M in   5.009253s
               hashr    136.990k (± 2.0%) i/s -    692.352k in   5.056100s
            hashugar      1.630M (± 2.9%) i/s -      8.182M in   5.024282s
           sd_struct      1.609M (± 6.0%) i/s -      8.047M in   5.020611s

Comparison:
            hashugar:  1629886.1 i/s
           sd_struct:  1609137.2 i/s - same-ish: difference falls within error
         hashie/mash:  1378083.4 i/s - 1.18x  slower
             ostruct:   609812.7 i/s - 2.67x  slower
               hashr:   136990.4 i/s - 11.90x  slower
```

### \#to_json
```sh
$ ruby bench/to_json.rb

\#to_json
OpenStruct: "#<OpenStruct a=\"a\", b=\"b\">"
Hashie::Mash: {"a":"a","b":"b"}
Hashr:
Hashugar: "#<Hashugar:0x00007fffdfbead98>"
SdStruct: {"a":"a","b":"b"}
Warming up --------------------------------------
         hashie/mash     6.444k i/100ms
           sd_struct    10.834k i/100ms
Calculating -------------------------------------
         hashie/mash     77.011k (± 1.7%) i/s -    386.640k in   5.021927s
           sd_struct    143.077k (± 2.0%) i/s -    715.044k in   4.999559s

Comparison:
           sd_struct:   143076.8 i/s
         hashie/mash:    77011.2 i/s - 1.86x  slower
``

### Deep \#to_h
```sh
$ ruby bench/deep_to_h.rb

Deep \#to_h
Hashie::Mash: {"a"=>#<Hashie::Mash b="b">}
Hashr: {:a=>{:b=>"b"}}
Hashugar: {"a"=>{:b=>"b"}}
SdStruct: {"a"=>{:b=>"b"}}
Warming up --------------------------------------
         hashie/mash    42.458k i/100ms
               hashr     9.632k i/100ms
            hashugar    49.011k i/100ms
           sd_struct    48.960k i/100ms
Calculating -------------------------------------
         hashie/mash      1.297M (± 4.6%) i/s -      6.496M in   5.020400s
               hashr    124.548k (± 1.5%) i/s -    626.080k in   5.028001s
            hashugar      1.947M (± 3.4%) i/s -      9.753M in   5.015420s
           sd_struct      1.894M (± 3.4%) i/s -      9.498M in   5.022113s

Comparison:
            hashugar:  1947158.3 i/s
           sd_struct:  1893594.3 i/s - same-ish: difference falls within error
         hashie/mash:  1297445.4 i/s - 1.50x  slower
               hashr:   124547.7 i/s - 15.63x  slower
```

### Deep \#to_json
```sh
$ ruby bench/deep_to_json.rb

Deep \#to_json
Hashie::Mash: {"a":{"b":"b"}}
Hashr:
Hashugar: "#<Hashugar:0x00007fffb95885c0>"
SdStruct: {"a":{"b":"b"}}
Warming up --------------------------------------
         hashie/mash     5.796k i/100ms
           sd_struct     9.692k i/100ms
Calculating -------------------------------------
         hashie/mash     62.437k (±16.3%) i/s -    301.392k in   5.043041s
           sd_struct    120.555k (±18.9%) i/s -    581.520k in   5.053842s

Comparison:
           sd_struct:   120555.1 i/s
         hashie/mash:    62437.1 i/s - 1.93x  slower
```

### Object Class
```sh
$ ruby bench/object_class.rb

JSON#parse :object_class
OpenStruct: #<OpenStruct object=#<OpenStruct a="bau bau", c="boo boo">, array=[#<OpenStruct one=1, two=2, three=3>], two words="Foo bar">
Hashie::Mash: #<Hashie::Mash array=#<Hashie::Array [#<Hashie::Mash one=1 three=3 two=2>]> object=#<Hashie::Mash a="bau bau" c="boo boo"> two words="Foo bar">
SdStruct: #<SdStruct object=#<SdStruct a="bau bau", c="boo boo">, array=[#<SdStruct one=1, two=2, three=3>], two words="Foo bar">
Warming up --------------------------------------
             ostruct   915.000  i/100ms
         hashie/mash     1.079k i/100ms
           sd_struct     1.045k i/100ms
Calculating -------------------------------------
             ostruct     11.261k (± 5.5%) i/s -     56.730k in   5.053413s
         hashie/mash     11.139k (± 1.4%) i/s -     56.108k in   5.037903s
           sd_struct     10.584k (± 4.6%) i/s -     53.295k in   5.045103s

Comparison:
             ostruct:    11261.4 i/s
         hashie/mash:    11139.5 i/s - same-ish: difference falls within error
           sd_struct:    10584.3 i/s - same-ish: difference falls within error
```

### SdStruct Getters
```sh
$ ruby bench/sd_struct_getters.rb

SdStruct Getters
Warming up --------------------------------------
        method chain    48.824k i/100ms
      xpath absolute     1.927k i/100ms
      xpath relative     1.394k i/100ms
Calculating -------------------------------------
        method chain      1.660M (± 3.2%) i/s -      8.300M in   5.004975s
      xpath absolute     20.278k (± 1.7%) i/s -    102.131k in   5.038094s
      xpath relative     14.291k (± 1.7%) i/s -     72.488k in   5.073917s

Comparison:
        method chain:  1660214.5 i/s
      xpath absolute:    20277.9 i/s - 81.87x  slower
      xpath relative:    14290.7 i/s - 116.17x  slower
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sd_struct'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sd_struct

## Attribution

Hashugar and OpenStruct are some of the primary sources of inspiration for this project.
It closely follows the way Hashugar takes nested hash input and the way OpenStruct
creates method on the first call.

## TODO

  * Add charts and tables for the benchmarks.


## Contributing

1. Fork it ( https://github.com/styd/sd_struct/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
