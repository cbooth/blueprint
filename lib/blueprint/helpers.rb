# frozen_string_literal: true

###############################################################################
# helpers.rb
# Provides helper functions to other internal classes.
# File-loading, processing, schema validation, and command line output.
#
# Copyright 2021-2022 Callum Booth
# Licensed under MIT
###############################################################################

require 'yaml'

require 'kwalify'

module Blueprint
  # Provides helper functions to other internal classes.
  class Helpers
    # Read file and normalise all line endings to \n.
    #
    # @param [String] filename The filename to open.
    #
    # @return [String] The file contents with normalised line endings.
    def self.munch_and_crunch(filename)
      File.open(filename, 'r') do |file|
        # Chomp and join is a nasty little hack that I'm not a fan of but
        # for some reason there was an issue with loaded files ending in just \r.
        # This may be because I'm developing this on Ubuntu for WSL but I can't be sure.
        file.readlines.map(&:chomp).join("\n")
      end
    end

    # Naively pluralise a string by just adding 's'.
    #
    # @param [String] str The string to pluralise.
    # @param [Numeric] count The count of +str+, to decide whether to pluralise or not.
    #
    # @return [String] The pluralised string if count > 1, +str+ otherwise.
    def self.naive_pluralise(str, count)
      if count > 1
        "#{str}s"
      else
        str
      end
    end

    # Augment the +TTY::Spinner+ class to add in features missing from the gem release.
    # Adds the ::log function from the tty-spinner Github repo, and defines << as an alias for log.
    # Allows +TTY::Command+'s output to be routed properly to STDOUT while +TTY::Spinner+ is running.
    def self.augment_tty_spinner
      # I hate this but it's necessary.
      # tty-spinner has a log function on github, but that change hasn't been pushed to RubyGems in months
      # So we'll inject the same code from github into the class ourselves
      #
      # We'll also add a << method to pipe text straight into the log function, this lets tty-command pipe
      #   output to the console without disrupting the spinner or needed a less prettier printer.
      TTY::Spinner.class_eval do
        define_method :log do |text|
          synchronize do
            cleared_text = text.to_s.lines.map do |line|
              TTY::Cursor.clear_line + line
            end.join

            write("#{cleared_text}#{"\n" unless cleared_text.end_with?("\n")}", false)

            return if done?

            write(TTY::Cursor.hide) if @hide_cursor && !spinning?

            data = message.gsub(/:spinner/, @frames[@current])
            data = replace_tokens(data)
            write(data, true)
          end
        end

        define_method :<< do |text|
          log(text)
        end
      end
    end

    # @return [Kwalify::Yaml::Parser] The YAML validator to check task specification validity.
    def self.make_parser
      schema = YAML.load_file("#{File.dirname __FILE__}/../../data/schema.yaml")
      validator = Kwalify::Validator.new(schema)
      Kwalify::Yaml::Parser.new(validator)
    end
  end
end
