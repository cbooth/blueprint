# frozen_string_literal: true

###############################################################################
# task.rb
# Provides task data layout classes.
#
# Copyright 2021-2022 Callum Booth
# Licensed under MIT
###############################################################################

require_relative 'error_handlers'

module Blueprint
  # Provides a structure to store task details in memory.
  class Task
    # @return [String] id The task ID.
    # @return [String] command The task command to run.
    # @return [String] name The task name.
    # @return [String] color The color to display task details in on the CLI.
    # @return [String] error Error rescue condition.
    attr_reader :id, :name, :description, :command, :color, :error, :error_task, :error_cmd

    # Create a new task.
    #
    # @param [String] id The task ID.
    # @param [String] command The task command to run.
    # @param [String] name The task name. Optional. Defaults to +command+ if not specified.
    # @param [String] color The color to display task details in on the CLI. Optional. Defaults to blue.
    # @param [String] error Error rescue condition. Optional. Defaults to 'throw' if not specified.
    def initialize(id, command, name: nil, description: nil, color: 'blue', error: nil)
      @id = id
      @command = command
      @color = color || 'blue'
      @error = error

      @name = name || command
      @description = description || ''
    end

    # Run the command.
    def run; end

    # @return [String] A string representation of the task.
    def to_s
      <<~TASK_STRING
        -------------------------
        Task ID: #{@id}
        Name: #{@name}
        Description: #{@description}
        Command: #{@command}
        Color: #{@color}
        On Error: #{@error}

      TASK_STRING
    end
  end
end
