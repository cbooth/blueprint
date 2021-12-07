# frozen_string_literal: true

###############################################################################
# tasklist.rb
# Defines classes to load task specifications from file.
# Provides tasklist constraining and validation functions.
#
# Copyright 2021-2022 Callum Booth
# Licensed under MIT
###############################################################################

require_relative 'errors'
require_relative 'helpers'
require_relative 'task'

module Blueprint
  # Loads blueprint task specifications in from file, validates, and formats tasks in memory.
  class Tasklist
    # @return [String] name The tasklist name.
    # @return [Array<Blueprint::Task>] tasks The tasks to run.
    attr_reader :name, :tasks

    # Creates a new Tasklist instance from a blueprint task specification file.
    #
    # @param [String] filename Filename of the task specification to load.
    def initialize(filename)
      parser = Helpers.make_parser
      tasklist_text = Helpers.munch_and_crunch(filename)
      parsed_tasklist = parser.parse(tasklist_text)
      errors = parser.errors

      if errors && !errors.empty?
        first_error = errors.first
        raise ValidationError.new(first_error.linenum, first_error.column, first_error.path, first_error.message)
      end

      @name = parsed_tasklist['name']
      @tasks = parsed_tasklist['tasks'].map do |task|
        Task.new(task['id'], task['command'], name: task['name'], description: task['description'],
                                              color: task['color'], error: task['error'])
      end
    end

    # Constrains the task list to a subset, either explicitly defined IN FILE ORDER, or from a range.
    #
    # Constraint order of precedence:
    #   1. A task sublist given by +task+
    #   2. A task range given by +to+ and/or +from+
    #   3. All tasks, if all params are nil
    #
    # Start with all tasks, and work up the order of precedence.
    #
    # @param [Array<String>] tasks A list of task IDs to be run in file order. Default: nil.
    # @param [String] from A task ID to begin a range from.
    # @param [String] to A task ID to end a range with.
    #
    # @return [Array<Blueprint::Task>] A constrained list of tasks ready for dispatch.
    def constrain(tasks: nil, from: nil, to: nil)
      to_run = @tasks
      to_run = extract_task_range(from: from, to: to) unless to.nil? & from.nil?
      to_run = extract_tasks(tasks) unless tasks.nil? || tasks.empty?

      to_run
    end

    # @return [Numeric] The number of tasks loaded.
    def task_count
      @tasks.length
    end

    # @return [String] A string representation of the task list.
    def to_s
      output = "Task: #{@name}\n"
      @tasks.each do |task|
        output << task.to_s
      end

      output
    end

    private

    # Extract a list of tasks from the task list by their IDs.
    # Tasks will be yielded in the order they appear in the task specification file, not in the order given.
    #
    # @param [Array<String>] task_list A list of task IDs to extract.
    #
    # @return [Array<Blueprint::Task>] The extracted list of tasks.
    def extract_tasks(task_list)
      valid_ids = task_list.map { |id| valid_id? id }
      raise InvalidTaskError, task_list[valid_ids.find_index(false)] unless valid_ids.all?

      @tasks.select { |task| task_list.include?(task.id) }
    end

    # Extract a range of tasks by specifying start and/or end IDs.
    #
    # @param [String] from A task ID to begin a range from.
    # @param [String] to A task ID to end a range with.
    #
    # @return [Array<Blueprint::Task>] The extracted range of tasks.
    def extract_task_range(from: nil, to: nil)
      # These checks were originally !nil & !valid
      #   But I De Morgan'd them like a compsci fresher
      #   Still not sure why, it's no more readable now than it was
      # Basically raise InvalidTaskError if `from`` or `to`` aren't valid, but only if they're not nil
      raise InvalidTaskError, from unless from.nil? | valid_id?(from)
      raise InvalidTaskError, to unless to.nil? | valid_id?(to)

      start_offset = from.nil? ? 0 : find_task_index_by_id(from)
      end_offset = to.nil? ? task_count : find_task_index_by_id(to) - start_offset + 1

      @tasks.slice(start_offset, end_offset)
    end

    # Locate the index of a task in the tasklist by its ID.
    #
    # @param [String] id The task ID to locate.
    #
    # @return [Numeric] The index of the specificed task.
    def find_task_index_by_id(id)
      @tasks.index(@tasks.find { |task| task.id == id })
    end

    # Check whether a task by the given ID exists in the current task list.
    #
    # @param [String] id The task ID to check.
    #
    # @return [true] if the task ID exists in the task list.
    def valid_id?(id)
      @tasks.map(&:id).include?(id)
    end
  end
end
