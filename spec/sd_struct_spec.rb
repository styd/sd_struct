require "spec_helper.rb"

describe SdStruct do
  let(:hash) do
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
  end
  let(:struct) { described_class.new(hash) }

  it "can access the data deeply with . (dots) or [] (square brackets)" do
    expect(struct.object.a).to eq "bau bau"
    expect(struct.object.c).to eq "boo boo"
    expect(struct.array[0].one).to eq 1
    expect(struct.array[0].two).to eq 2
    expect(struct.array[0].three).to eq 3
    expect(struct["two words"]).to eq "Foo bar"
  end

  it "can reassign value to members" do
    struct.object.a = "foo foo"
    h = hash.dup
    h[:object][:a] = "foo foo"

    expect(struct.object.a).to eq "foo foo"
    expect(struct).to eq described_class.new(h)
  end

  it "can convert hash assigned to its member to its own class" do
    object = {:a => "bau bau", :b => "foo foo", :c => "boo boo"}
    array = [{:four => 4, :five => 5, :six => 6}]

    struct.object = object
    struct.array = array

    h = hash.dup
    h[:object] = object
    h[:array] = array

    expect(struct.object.b).to eq "foo foo"
    expect(struct.array[0].five).to eq 5
    expect(struct).to eq described_class.new(h)
  end

  it "can be returned back to hash" do
    expect(described_class.new(hash).to_h).to eq hash
    expect(described_class.new(described_class.new(hash)).to_h).to eq hash
  end

  it "responds to key set earlier" do
    struck = described_class.new name: "Barry Allen"
    expect(struck).to respond_to :name
    expect(struck).to respond_to :name=
    struck.by_lightning = { be: "The Flash" }
    expect(struck).to respond_to :by_lightning
    expect(struck).to respond_to :by_lightning=
  end

  it "equals to its kind" do
    s1 = described_class.new
    s2 = described_class.new
    expect(s1).to eq s2

    s1.a = 'a'
    expect(s1).not_to eq s2

    s2.a = 'a'
    expect(s1).to eq s2

    s1.a = 'b'
    expect(s1).not_to eq s2

    s2.a = 'b'
    expect(s1).to eq s2
  end

  it "doesn't change the hash being passed" do
    struct.a = "a"
    expect(struct.a).to eq "a"
    expect(struct.to_h).not_to eq hash
  end

  it "inspects as OpenStruct would inspect" do
    foo = described_class.new
    expect(foo.inspect).to eq "#<#{described_class}>"
    foo.bar = 1
    foo["bazaar?"] = 2
    foo["et al."] = 3
    foo["a=4, b"] = 5
    expect(foo.inspect).to eq "#<#{described_class} bar=1, bazaar?=2, et al.=3, a=4, b=5>"
    expect(foo.inspect.frozen?).to eq false

    foo = described_class.new
    foo.bar = described_class.new
    expect(foo.inspect).to eq "#<#{described_class} bar=#<#{described_class}>>"

    foo.bar.foo = foo
    expect(foo.inspect).to eq "#<#{described_class} bar=#<#{described_class} foo=#<#{described_class} ...>>>"
    expect(foo.inspect.frozen?).to eq false
  end

  it "can dig deep with xpath like syntax" do
    expect(struct.find('//a')).to eq "bau bau"
    expect(struct.find('///a')).to eq "bau bau"
    expect(struct.find('object/b')).to eq nil
    expect(struct.find('object/c')).to eq "boo boo"
    expect(struct.find('object//a')).to eq "bau bau"
    expect(struct.find('//one')).to eq 1
    expect(struct.find('//four')).to eq nil
    expect(struct.find('array//two')).to eq 2
    expect(struct.find('//two words')).to eq "Foo bar"
  end
end
