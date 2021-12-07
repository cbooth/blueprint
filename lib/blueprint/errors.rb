# frozen_string_literal: true

###############################################################################
# errors.rb
# Defines Blueprint-specific errors
#
# Copyright 2021-2022 Callum Booth
# Licensed under MIT
###############################################################################

module Blueprint
  # Raised when too many task specifications are given and Blueprint can't decide which one to run.
  # (This behaviour may be changed in future to choose a task spec based on an order of precedence.)
  class TooManyPathsError < StandardError
    # @return [Array<String>] paths The task spec paths that were given.
    attr_reader :paths

    # @param [Array<String>] paths The task spec paths that were given.
    def initialize(paths)
      @paths = paths
      @summary = 'Too many task specification paths were specified!'

      super(@summary)
    end

    # @return [String] The error message.
    def message
      "#{@summary}. Multiple paths #{@paths.join(',')} were given. Please pass only one."
    end
  end

  # Raised when the task specification does not exist or could not be found and loaded.
  class NoTaskSpecError < StandardError
    # @return [String] path The task spec path given.
    attr_reader :path

    # @param [String] path The task spec path given.
    def initialize(path)
      @path = path
      @summary = 'Task specification was not found!'

      super(@summary)
    end

    # @return [String] The error message.
    def message
      "#{@summary}. #{@path} does not exist."
    end
  end

  # Raised when a task ID is specified in run constraints that is not found in the blueprint task specification.
  class InvalidTaskError < StandardError
    # @return [String] id The task ID given.
    attr_reader :id

    # @param [String] id The task ID given.
    def initialize(id)
      @id = id
      @summary = 'Task ID is invalid!'

      super(@summary)
    end

    # @return [String] The error message.
    def message
      "#{@summary}. #{@id} was not found in given blueprint."
    end
  end

  # Raised when the blueprint task specification fails validation against the internal schema.
  class ValidationError < StandardError
    # @return [Numeric] line_number The line number containing the validation error.
    # @return [Numeric] column_number The column number of the validation error.
    # @return [String] path The path to the erroneous task spec.
    # @return [String] message The error message returned from the validator.
    attr_reader :line_number, :column_number, :path, :message

    # @param [Numeric] line_number The line number containing the validation error.
    # @param [Numeric] column_number The column number of the validation error.
    # @param [String] path The path to the erroneous task spec.
    # @param [String] message The error message returned from the validator.
    def initialize(line_number, column_number, path, msg)
      @line_number = line_number
      @column_number = column_number
      @path = path
      @msg = msg

      @summary = 'Blueprint configuration was malformed!'

      super(@summary)
    end

    # @return [String] The error message.
    def message
      "#{@summary}, at #{@column_number}:#{@line_number} (#{@path}): #{@msg}."
    end
  end
end
