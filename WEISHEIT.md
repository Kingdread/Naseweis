# `Weisheits`-files

A `Weisheits`-fiile is a YAML file that describes the questions that should be
asked.

The top level element should be a list of questions, whereas the syntax of a
question is described below.

## question objects

A question is a simple dictionary of various "modifiers", which allow you to
customize the behaviour.

Available options are:

### `q`

The actual question as a string, which is then used as a prompt, or a list of
subquestions. If this attribute is a string, then the input will be saved,
otherwise a dictionary of the sub-question responses will be saved.

#### Examples

```yaml
# Simple string question
- q: "What is your name?"
  target: user_name

# Subquestions
- target: user_data
  q:
  - q: "User name?"
    target: name
  - q: "User email?"
    target: email
```

In the first case, the result is available via `result["user_name"]`, in the
second case, the name is saved as `result["user_data"]["name"]` and
`result["user_data"]["email"]`.

### `target`

The name of the target variable, which will contain the user data.

If the question is a normal string, the data is saved as a string.  If the
question has subquestions, the data is a hash, which contains the subquestions
data.  If the question is repeated, the data is saved as a list of separate
inputs.  If the question has a type specified, it will be type-converted.

### `desc`

Description of the question, which will be printed before the question is
asked. This is useful e.g. for repeating questions, as it will be displayed
once (while the prompt will be displayed multiple times). It can also be used
as a "print" function if no question data is gathered.

#### Examples

```yaml
- desc: "Just print something"

- desc: "Gather some lines, input an empty line to finish"
  repeat: true
  target: lines
```

### `repeat`

Define if the question should be repeated. A repeated question will save its
result as a list. The prompt is displayed at each iteration, if you only want
to display it once, use `desc` instead.

There are multiple ways a question can be repeated:

* `repeat: true`: repeat until an empty line is entered.
* `repeat: 3`: repeat 3 times.
* `repeat: "Continue?"`: ask the given prompt, if it is answered with "yes",
  repeat the question again.

Note that the presence of the `repeat` attribute is enough to force the answer
to be a list, even if the actual question produces 0 or 1 inputs.

#### Examples

```yaml
- desc: "Enter your address, end with an empty line"
  repeat: true
  target: address

- prompt: "Your sibling's name?"
  target: siblings
  repeat: "Do you have another sibling?"
```

### `type`

Type of the question. This is used to both verify the input and convert it to
the native Ruby type.

Valid types are:

* `int`, `integer`: Integer

## Nesting questions

Questions can be nested arbitrarily deep, if you want to make an address book,
you could do something like

```yaml
- desc: "Fill your address book!"
  repeat: "Add another contact?"
  target: contacts
  q:
  - q: "Contact name?"
    target: name
  - q: "Contact address?"
    target: address
  - desc: "Additional information (end with an empty line)"
    repeat: true
    target: information
```

Processing the file will lead to the following interaction:

```
>>> Fill your address book!
>>> Contact name?
Darth Vader
>>> Contact address?
Death Star
>>> Additional information (end with an empty line)
Very nice guy!

>>> Add another contact?
yes
>>> Contact name?
Luke Skywalker
>>> Contact address?
Dagobah
>>> Additional information (end with an empty line)

>>> Add another contact?
no
```

And finally to the Ruby structure:

```ruby
{
  "contacts"=>[
    {
      "name"=>"Darth Vader",
      "address"=>"Death Star",
      "information"=>["Very nice guy!"]
    },
    {
      "name"=>"Luke Skywalker",
      "address"=>"Dagobah",
      "information"=>[]
    }
  ]
}
```
