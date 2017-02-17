# LightParams

This is a better structure for the has. Thanks to this class you can from symbolized/stringify hash extract what you need with proper transformation values and keys.

## Examples

```ruby
# class Pet
class Pet < LightParams::Lash
  property :name,  from: :nickname
end

# class Person
class Person < LightParams::Lash
  properties :first_name, :last_name
  property :age, with: -> (v) { v.to_i }
  property :created_at, with: :to_date
  property :parents, collection: Person, compact: true
  property :pet, model: Pet
  property :children, collection: true, uniq: true do
    properties :first_name, :last_name
    property :age, with: -> (v) { v.to_i }
    property :date, from: :created_at, with: :to_date
    property :sex, default: :unknown
  end

  private

  def to_date(value)
    DateTime.parse(value)
  end
end

# hash
source = {
  first_name: 'Pawel',
  last_name: 'Niemczyk',
  'age' => '30',
  'created_at' => '1983-09-07T18:37:52+02:00',
  pet: {
    nickname: 'Brutus'
  },
  parents: [
    {
      first_name: 'Wladyslaw',
      "last_name" => 'Niemczyk'
    },
    nil
  ],
  children: [
    {
      first_name: 'Emilia',
      'last_name' => 'Niemczyk',
      age: '4',
      created_at: '2011-02-11T18:37:52+02:00'
    },
    {
      first_name: 'Tomasz',
      last_name: 'Niemczyk',
      'age' => '2',
      created_at: '2012-06-27T18:37:52+02:00'
    },
    {
      first_name: 'Tomasz',
      'last_name' => 'Niemczyk',
      age: '2',
      created_at: '2012-06-27T18:37:52+02:00'
    } 
  ]
}

person = Person.new(source)

# date was changed by `from` modificator from `created_at` to `date` and by `with` value was transformed by `:to_date` method
person.children.first.date # => `Fri, 11 Feb 2011 18:37:52 +0200`
person.children.first.sex  # => `:unknown` was set by `default` modificator
person.children.first.age  # => 4
person.children.count      # => 2  # children are uniq by `uniq` modificator
person.parents.count       # => 1  # nil value was removed by `compact` modificator
person.parents.first.children # => [] # it is collection so by default empty it will be empty array

json          = source.to_json
person_object = Person.from_json(json) # this will recreate person object from json
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'light_params'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install light_params

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/light_params/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
