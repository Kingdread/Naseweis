# Naseweis

`Naseweis` is a Ruby library if you have a lot of user input to gather. It lets
you define your "questions" in a so called `Weisheits`-file, which is then read
by `Naseweis` and user input is gathered.

## Example

`Weisheits`-file `questions.yaml`:

```yaml
- q: "What's your name?"
  target: name

- q: "How many times should I greet you?"
  target: times
  type: int
```

Ruby source `main.rb`:

```ruby
require "Naseweis"
nase = Naseweis::Nase.new "questions.yaml"
nase.read
result = nase.interrogate
name = result["name"]
result["times"].times { puts "Hello, #{name}" }
```

## Weisheit

The `Weisheits` format is a normal YAML file, which defines questions, their
target name, their type, and some more information.

The full description can be found in WEISHEIT.md.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'Naseweis'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install Naseweis

## Documentation

Documentation is available at http://kingdread.github.io/Naseweis

## License

The MIT License (MIT)

Copyright (c) 2016 Daniel Schadt

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
