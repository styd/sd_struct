# SDStruct

An alternative to OpenStruct that is stricter in assigning values and deeper in
consuming the passed Hash and transforming it back to Hash or JSON, equipped
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

#### In OpenStruct, it's not obvious how to get a value with fields that contain
spaces. Some people don't even know that it can be accessed.

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
```

#### OpenStruct's `to_h` doesn't return a hash deeply.

```ruby
## with OpenStruct
o_struct.to_h
# => {:object=>#<OpenStruct a="bau bau", c="boo boo">,
# :array=>[#<OpenStruct one=1, two=2, three=3>], :"two words"=>"Foo bar"}

## with SDStruct
sd_struct.to_h
# => {:object=>{:a=>"bau bau", :c=>"boo boo"},
# :array=>[{:one=>1, :two=>2, :three=>3}], "two words"=>"Foo bar"}
```

### From Hash

Example of a Hash.

```ruby

```

```ruby
## with OpenStruct
o_struct = OpenStruct.new(hash)
# =>

## with SDStruct
sd_struct = SDStruct.new(hash)
```

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


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sd_struct'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sd_struct

## Contributing

1. Fork it ( https://github.com/styd/sd_struct/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
