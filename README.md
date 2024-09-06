# Contours

Contours provids objects for building configuration.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add contours

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install contours

## Usage

Build a configuration object by creating a class that inherits from `Contours::BlendedHash` and define the configuration attributes.

Specify a list of keys that should be blended into the configuration object by setting the `@blended_keys` variable on the class.

```ruby
class Configuration < Contours::BlendedHash
  @blended_keys = %i[class data]
end
```

Create a new object using `init`

```ruby
config = Configuration.init({class: "test", data: [1, 2, 3]})
```

The `config` object will be able to be merged with other configuration objects.

```ruby
config.merge(Configuration.init({class: "overwrite", data: [4, 5, 6]}))

config.to_h # => {class: "overwrite", data: [1, 2, 3, 4, 5, 6]}
```

You can specify a custom way to blend the values for the `@blended_keys`

```ruby
class Configuration < Contours::BlendedHash
  @blended_keys = %i[class data]

  blend(:class, with: Contours::StructuredString)

  blend :data do |existing, new_value|
    existing.sum(new_value.sum)
  end
end

config.merge(Configuration.init({class: "overwrite", data: [4, 5, 6]}))

config.to_h # => {class: "test overwrite", data: 21}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

This project is managed with [Reissue](https://github.com/SOFware/reissue).

To release a new version, make your changes and be sure to update the CHANGELOG.md.

To release a new version:

1. `bundle exec rake build:checksum`
2. `bundle exec rake release`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SOFware/contours.
