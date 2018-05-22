# Lolcommits Flowdock

[![Gem](https://img.shields.io/gem/v/lolcommits-flowdock.svg?style=flat)](http://rubygems.org/gems/lolcommits-flowdock)
[![Travis](https://travis-ci.org/lolcommits/lolcommits-flowdock.svg?branch=master)](https://travis-ci.org/lolcommits/lolcommits-flowdock)
[![Depfu](https://img.shields.io/depfu/lolcommits/lolcommits-flowdock.svg?style=flat)](https://depfu.com/github/lolcommits/lolcommits-flowdock)
[![Maintainability](https://api.codeclimate.com/v1/badges/ad7324f710e10daffd52/maintainability)](https://codeclimate.com/github/lolcommits/lolcommits-flowdock/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/ad7324f710e10daffd52/test_coverage)](https://codeclimate.com/github/lolcommits/lolcommits-flowdock/test_coverage)

[lolcommits](https://lolcommits.github.io/) takes a snapshot with your webcam
every time you git commit code, and archives a lolcat style image with it. Git
blame has never been so much fun!

This plugin automatically posts lolcommit images to a Flowdock flow (room) with
the `#lolcommits` hashtag. They wll appear like this:

![example
commit](https://github.com/lolcommits/lolcommits-flowdock/raw/master/assets/images/example-commit.png)

## Requirements

* Ruby >= 2.0.0
* A webcam
* [ImageMagick](http://www.imagemagick.org)
* [ffmpeg](https://www.ffmpeg.org) (optional) for animated gif capturing
* A [Flowdock](https://www.flowdock.com) account

## Installation

After installing the lolcommits gem, install this plugin with:

    $ gem install lolcommits-flowdock

Then configure to enable with:

    $ lolcommits --config -p flowdock
    # set enabled to `true`
    # paste your Flowdock personal API token (from https://flowdock.com/account/tokens)
    # set your Flowdock organization (tab to autocomplete)
    # set the Flowdock flow to post messages to (tab to autocomplete)

That's it! Your next lolcommit will be posted as a new message to the flow. To
disable uninstall this gem or use:

    $ lolcommits --config -p flowdock
    # and set enabled to `false`

## Development

Check out this repo and run `bin/setup`, this will install all dependencies and
generate docs. Use `bundle exec rake` to run all tests and generate a coverage
report.

You can also run `bin/console` for an interactive prompt, allowing you to
experiment with the gem code.

## Tests

MiniTest is used for testing. Run the test suite with:

    $ rake test

## Docs

Generate docs for this gem with:

    $ rake rdoc

## Troubles?

If you think something is broken or missing, please raise a new
[issue](https://github.com/lolcommits/lolcommits-flowdock/issues). Take
a moment to check it hasn't been raised in the past (and possibly closed).

## Contributing

Bug [reports](https://github.com/lolcommits/lolcommits-flowdock/issues) and [pull
requests](https://github.com/lolcommits/lolcommits-flowdock/pulls) are welcome on
GitHub.

When submitting pull requests, remember to add tests covering any new behaviour,
and ensure all tests are passing on [Travis
CI](https://travis-ci.org/lolcommits/lolcommits-flowdock). Read the
[contributing
guidelines](https://github.com/lolcommits/lolcommits-flowdock/blob/master/CONTRIBUTING.md)
for more details.

This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the [Contributor
Covenant](http://contributor-covenant.org) code of conduct. See
[here](https://github.com/lolcommits/lolcommits-flowdock/blob/master/CODE_OF_CONDUCT.md)
for more details.

## License

The gem is available as open source under the terms of
[LGPL-3](https://opensource.org/licenses/LGPL-3.0).

## Links

* [Travis CI](https://travis-ci.org/lolcommits/lolcommits-flowdock)
* [Test Coverage](https://codeclimate.com/github/lolcommits/lolcommits-flowdock/test_coverage)
* [Maintainability](https://codeclimate.com/github/lolcommits/lolcommits-flowdock/maintainability)
* [RDoc](http://rdoc.info/projects/lolcommits/lolcommits-flowdock)
* [Issues](http://github.com/lolcommits/lolcommits-flowdock/issues)
* [Report a bug](http://github.com/lolcommits/lolcommits-flowdock/issues/new)
* [Gem](http://rubygems.org/gems/lolcommits-flowdock)
* [GitHub](https://github.com/lolcommits/lolcommits-flowdock)
