# Blueprint

Blueprint is a language-agnostic, task-agnostic, project-agnostic, just generally very agnostic, task-runner. Simply describe the steps of your task in a very concise YAML file at the root of your project, and run `$ blueprint` to build, or deploy, or run, or serve, or whatever it is you need to get your project going. Think of it like `$ npm run ...` but in Ruby.

[![CodeQL](https://github.com/cbooth/blueprint/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/cbooth/blueprint/actions/workflows/codeql-analysis.yml)
[![GitHub issues](https://img.shields.io/github/issues/cbooth/blueprint)](https://github.com/cbooth/blueprint/issues)
## Usage

```
Usage: blueprint [PATH] [options]

Specific options:
        --task x,y,z                 A specific task or list of single tasks to be run in given sequence
        --from TASK                  A specific task to run the blueprint from
        --to TASK                    A specific task to run the blueprint to

Examples:
                    Run the tasklist in the current working directory's .blueprint file
                        $ blueprint

                    Run the tasklist from a different file
                        $ blueprint path/to/blueprint.yml

                    Run one individual task from the tasklist
                        $ blueprint --task third_task

                    Run a range of tasks from the tasklist
                        $ blueprint --from third_task --to sixth_task

Common options:
    -h, --help                       Show this message
        --version                    Show version

```

## Creating your .blueprint file

Every project blueprint is described by a very simple YAML file called `.blueprint` at the root of your project. This file is called a Blueprint Task Specification, and there's some liberty with what you can call this file or where it can be stored. `.blueprint` at the root of your project allows the Task Specification to be run with just `$ blueprint`, but with the `--path` option, you can place it anywhere, call it anything.

Each `.blueprint` consists of an optional blueprint name, and a list of tasks defined as so:

```
---
name: My awesome project - build and deploy
tasks:
    - 
        id: commit
        name: Commit code changes
        command: git commit -m "deploy"
    - 
        id: push
        name: Push to git
        description: This is an optional field to give a longer description.
        command: git push
    -
        id: check
        name: Load the webpage
        description: Load the webpage to check the code pushed correctly. Hey what if we made this one green.
        color: green  # Oh look at that
        command: start https://my-awesome-site.fake/

```
The full schema, in Kwalify YAML is shown below:

```
---
type: map
required: yes
mapping:
  "name": {type: str, required: no, unique: no}
  "tasks":
    type: seq
    required: yes
    sequence:
      - 
        type: map
        required:  yes
        mapping:
          "id": {type: str, required: yes, unique: yes}
          "name": {type: str, required: no, unique: no}
          "description": {type: str, required: no, unique: no}
          "command": {type: str, required: yes, unique: no}
          "color": {type: str, required: no, unique: no}
          "error": {type: str, required: no, unique: no}

```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/blueprint. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/blueprint/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Blueprint project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/blueprint/blob/master/CODE_OF_CONDUCT.md).
