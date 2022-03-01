# Cobhan

Cobhan FFI is a proof of concept system for enabling shared code to be written in Rust or Go and consumed from all major languages/platforms in a safe and effective way, using easy helper functions to manage any unsafe data marshaling.

## Types

* Supported types
  * int32 - 32bit signed integer
  * int64 - 64bit signed integer
  * float64 - double precision 64bit IEEE 754 floating point
  * Cobhan buffer - length delimited 8bit buffer (no null delimiters)
      * utf-8 encoded string
      * JSON
      * binary data
* Cobhan buffer details
  * Callers provide the output buffer allocation and capacity
  * Called functions can transparently return larger values via temporary files
  * **Modern [tmpfs](https://en.wikipedia.org/wiki/Tmpfs) is entirely memory backed**
* Return values
  * Functions that return scalar values can return the value directly
    * Functions *can* use special case and return maximum positive or maximum negative or zero values to represent error or overflow conditions
    * Functions *can* allow scalar values to wrap
    * Functions should document their overflow / underflow behavior

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cobhan'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install cobhan
```

## Usage

By running the demo, it will automatically build the sample [libcobhandemo](spec/support/libcobhandemo/libcobhandemo.go) binary.

```bash
bundle exec ruby demo/demo.rb
```

Once the binary is built, to rebuilt it, you'll have to cleanup the `tmp` dir.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Running specs

```bash
bundle exec rspec spec
```

### Running specs inside vagrant

```bash
vagrant up
vagrant ssh
cd /vagrant/
bundle install
bundle exec rspec spec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/godaddy/cobhan-ruby.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).
