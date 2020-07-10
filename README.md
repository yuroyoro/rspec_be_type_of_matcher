# RspecBeTypeOfMatcher

Rspec matchers for strucural type assertion. Compare values of array to have all expeted_type, hash's key and value are expeted type.

You can use this matcher to asert the actual value have expected type like bellow.

```ruby

# assert array of Symbol
expect([:foo, :bar]).to be_type_of([Symbol])

# assert hash key and value
expect({ foo: 1, bar: 2 }).to be_type_of({ Symbol # => String })
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec_be_type_of_matcher'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec_be_type_of_matcher

## Usage

### Or pattern

ex) assert the value is a String or Symbol

```ruby
  # rspec build-in matcher
  expect(:foo).to be_kind_of(String).or be_kind_of(Symnbol)

  # ↓
  expect("foo").to be_type_of(String, Symnbol)
  expect(:foo).to be_type_of(String, Symnbol)
  # => ok

  expect(1).to be_type_of(String, Symnbol)
  # => fali
```

### Allow nil value

allow to conain nil value in actual collection.

ex) assert the value is a String or nil

```ruby
  # rspec built-in matcher
  expect(:foo).to be_nil.or be_kind_of(String)

  # ↓
  expect("foo").to be_type_of(String).or_nil
  expect(nil).to be_type_of(String).or_nil
  # => ok
```

### TrueClass/FalseClass

ex) assert the value is a boolean

```ruby
  expect(true).to be_type_of(:boolean)
  # => ok

  expect(:foo).to be_type_of(:boolean)
  # => fail
```

### Array pattern

ex) assert the value is a Array of String

```ruby
  # rspec built-in matcher
  expect(["foo", "bar"]).to all(be_type_of(String))
  # => ok

  # ↓
  expect(["foo", "bar"]).to be_type_of([String])
  # => ok

  expect(["foo", :bar]).to be_type_of([String])
  # => fail
```

Array pattern must exactly 1 value

```ruby
  expect(["foo", :bar]).to be_type_of([String, Symbol])
  # => error
```

ex) assert the value is a Array of (String or Symbol)

```ruby
  # rspec built-in matcher
  expect(["foo", :bar]).to all(be_kind_of(String).or be_kind_of(Symbol))

  # ↓
  expect(["foo", :bar]).to be_type_of([be_type_of(String, Symbol)])
  # => ok
```

### Hash pattern

ex) assert the value is a Hash those key is Symbol and value is String

```ruby
  # rspec built-in matcher
  expect({foo: "aaa"}.keys).to all(be_kind_of(Symbol))
  expect({foo: "aaa"}.values).to all(be_kind_of(String))

  # ↓
  expect({foo: "aaa"}).to be_type_of(Symbol => String)
  # => ok

  expect({foo: "aaa", bar: :bbb}).to be_type_of(Symbol => String)
  # => fail
```

Hash pattern must exactly 1 entry

```ruby
  expect({foo: "aaa"}).to be_type_of(Symbol => String, Integer => String)
  # => error
```

with composit matcher on values

```ruby
  expect({foo: "aaa", bar: 1}).to be_type_of(Symbol => be_type_of(Symbol, Integer))
  # => ok
```

with composit matcher on key and values

```ruby
  expect({foo: "aaa", "bar" => 1}).to be_type_of(
    be_type_of(
      be_type_of(String, Symbol) => be_type_of(Symbol, Integer)
    )
  )
  # => ok
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rspec_be_type_of_matcher. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RspecBeTypeOfMatcher project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rspec_be_type_of_matcher/blob/master/CODE_OF_CONDUCT.md).
