# SDStruct

An alternative to OpenStruct that is more strict in assigning values and deeper
in consuming the passed Hash and transforming it back to Hash or JSON, equipped
with deep digging capabilities.

## Usage

### From JSON

Example of a response body in JSON.

```JSON
{
  "object": {
    "a": "bau bau",
    "c": "boo boo"
  },
  "array": [
    {
      "one": 1,
      "two": 2,
      "three": 3
    }
  ],
  "two words": "Foo bar"
}
```


> In OpenStruct, it's not obvious how to get a value with fields that contain spaces.
> Some people don't even know that it can be accessed.

```ruby
## with OpenStruct
o_struct = JSON.parse(response.body, object_class: OpenStruct)
# => #<OpenStruct object=#<OpenStruct a="bau bau", c="boo boo">,
# array=[#<OpenStruct one=1, two=2, three=3>], two words="Foo bar">

o_struct["two words"]
# => "Foo bar"


## with SDStruct
sd_struct = JSON.parse(response.body, object_class: SDStruct)
# => #<SDStruct .object=#<SDStruct .a="bau bau", .c="boo boo">,
# .array=[#<SDStruct .one=1, .two=2, .three=3>], ['two words']="Foo bar">

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

## SDStruct
sd_struct.to_h
# => {:object=>{:a=>"bau bau", :c=>"boo boo"},
# :array=>[{:one=>1, :two=>2, :three=>3}], "two words"=>"Foo bar"}
```


> OpenStruct uses `method_missing` to create new field, while SDStruct prevent creation
> of new field using dot notation.

SDStruct prevent creation of new field using dot notation once it is initialized
to prevent assigning unintended field when you mistyped the key/field. SDStruct
is stricter in that way. However, SDStruct can also be lenient. You can use
square brackets when you want to assign a new field.

```ruby
## OpenStruct
o_struct.book = "title"
# => "title"

o_struct
# => #<OpenStruct object=#<OpenStruct a="bau bau", c="boo boo">,
# array=[#<OpenStruct one=1, two=2, three=3>], two words="Foo bar", book="title">


## SDStruct
sd_struct.book = "title"
# => NoMethodError: undefined method `book=' for #<SDStruct:0x007ffa65b10a28>

sd_struct["book"] = "title"
# => "title"

sd_struct
# => #<SDStruct .object=#<SDStruct .a="bau bau", .c="boo boo">,
# .array=[#<SDStruct .one=1, .two=2, .three=3>], ['two words']="Foo bar", .book="title">
```


> OpenStruct doesn't have search or deep digging functionalities

```ruby
sd_struct.find('object/a')
# => "bau bau"

sd_struct.find('array/0/one')
# => 1

sd_struct.find('object->a', separator: '->')
# => "bau bau"

sd_struct.find('array.0.one', separator: '.')
# => 1

# You can push it to find deeper. It will return the first occurrence of the matched field
sd_struct.find('a')
# => "bau bau"

sd_struct.find('0/one')
# => 1

sd_struct.find('one')
# => 1

sd_struct.find('four')
# => nil

sd_struct.dig_deep(0, :one)
# => 1

sd_struct.dig_deep(:one)
# => 1
```


> SDStruct is suitable for building JSON request body

You can parse a default JSON file for request body, fill it in, and only send
parts that are not empty.

```ruby
# SDStruct also has `delete_field` method
sd_struct.delete_field(:book)
# => #<Class:#<SDStruct:0x007ffa65b10a28>>

sd_struct
# => #<SDStruct .object=#<SDStruct .a="bau bau", .c="boo boo">,
# .array=[#<SDStruct .one=1, .two=2, .three=3>], ['two words']="Foo bar">

sd_struct.find('0').one = 0
sd_struct.find('0').three = 0
sd_struct['two words'] = ""
sd_struct
# => #<SDStruct .object=#<SDStruct .a="bau bau", .c="boo boo">,
# .array=[#<SDStruct .one=0, .two=2, .three=0>], ['two words']="">
```

By default, blank value, 0, [""], and [{}] are considered not important.
Therefore, keys with those values are excluded from the generated JSON string.

```ruby
sd_struct.to_json
# => "{\"object\":{\"a\":\"bau bau\",\"c\":\"boo boo\"},\"array\":[{\"two\":2}]}"

sd_struct.find('0').two = 0
sd_struct.to_json
# => "{\"object\":{\"a\":\"bau bau\",\"c\":\"boo boo\"}}"
```

However, you can include them if you want to by removing them from `:values_to_exclude` option.

```ruby
sd_struct.to_json values_to_exclude: [[""], [{}]] # default to [0, [""], [{}]]
# => "{\"object\":{\"a\":\"bau bau\",\"c\":\"boo boo\"},\"array\":[{\"one\":0,\"two\":0,\"three\":0}]}"

sd_struct.to_json values_to_exclude: [[""], [{}]], exclude_blank_values: false # default to true
# => "{\"object\":{\"a\":\"bau bau\",\"c\":\"boo boo\"},\"array\":[{\"one\":0,\"two\":0,\"three\":0}],\"two words\":\"\"}"
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

## with SDStruct
sd_struct = SDStruct.new(hash)
# => #<SDStruct .object=#<SDStruct .a="bau bau", .c="boo boo">,
# .array=[#<SDStruct .one=1, .two=2, .three=3>], ['two words']="Foo bar">
```

## Reserved Field Names

`delete_field`, `delete_key`, `dig`, `dig_deep`, `each_pair`, `fields`, `find`,
`keys`, `marshal_dump`, `marshal_load`, `new_struct_member`, `non_spaced_keys`,
`spaced_keys`, `structurize`, `table`, `to_h`, `to_json`

## Dependencies

ActiveSupport (if you use Rails, this should already be installed)

### ActiveSupport Installation (for when you don't use Rails)

Add this line to your application's Gemfile:

```ruby
gem 'activesupport'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activesupport

In your code:

```ruby
require 'active_support/all'
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

If you're not using rails, you can choose to only require the minimal version
that doesn't have deep search and deep convert capabilities.

```ruby
require 'sd_struct/base'
```

## Contributing

1. Fork it ( https://github.com/styd/sd_struct/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
