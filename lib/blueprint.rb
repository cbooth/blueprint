# frozen_string_literal: true

###############################################################################
# blueprint.rb
# Defines the main CLI entrypoint into Blueprint.
# Provides tasklist loading, command dispatch, and CLI rendering.
#
# Copyright 2021-2022 Callum Booth
# Licensed under MIT
###############################################################################

require 'pastel'
require 'tty-command'
require 'tty-logger'
require 'tty-progressbar'
require 'tty-spinner'

require_relative 'blueprint/errors'
require_relative 'blueprint/helpers'
require_relative 'blueprint/tasklist'

# Blueprint
module Blueprint
  # Main CLI entrypoint for Blueprint, handles loading command lists and dispatching to the OS
  class Blueprint
    # Sets up the main CLI.
    def initialize
      @pastel = Pastel.new
      @logger = TTY::Logger.new
      Helpers.augment_tty_spinner
    end

    # Reads the task list, applies contraints, dispatches commands, and displays output.
    #
    # @param [String] path The task spec path.
    # @param [Hash<String, String>] args Constraints captured from command line switches.
    #
    # @return [Hash<String, String] Task run statistics (failures, failure count, number of tasks ran).
    def go(path, args)
      # Process args
      path = sanitise_path(path)

      tasks = args[:tasks]
      from = args[:from]
      to = args[:to]

      bp = Tasklist.new(path)

      @logger.info("Blueprint #{bp.name.empty? ? nil : @pastel.blue(bp.name)} " \
                   "started from #{@pastel.blue path}, found #{bp.task_count} tasks.")

      working_task_list = bp.constrain(tasks: tasks, from: from, to: to)
      working_task_length = working_task_list.length

      # If any constraints have been added to the task run, inform the user by:
      #   Displaying how many tasks will now be run
      #   Which tasks will run in which order
      #   Colour the task names for a bit of fun
      # Trigger this on the assumption that constraints will make the working task list shorter.
      if working_task_length < bp.task_count
        @logger.info('Task list has been constrained to ' \
                      "#{working_task_length} #{Helpers.naive_pluralise('task', working_task_length)}: " \
                      "#{working_task_list.collect { |task| @pastel.decorate(task.id, task.color.to_sym) }.join(', ')}")
      end

      dispatch_tasks(working_task_list)
    end

    private

    # Checks for a sane path to a task spec, default it to ./.blueprint if none given.
    # Raises +Blueprint::TooManyPathsError+ if too many paths are given and Blueprint cannot decide which to run.
    # This behaviour is subject to change as I may explore some kind of logic to choose the best path to try.
    #
    # Raises +Blueprint::NoTaskSpecError+ if the task spec does not exist.
    #
    # @param [Array<String>] paths List of paths to try.
    #
    # @return [String] The path to load as a task specification.
    def sanitise_path(paths)
      raise TooManyPathsError, paths if paths.length > 1

      path = paths.first || './.blueprint'

      raise NoTaskSpecError, path unless File.exist?(path)

      path
    end

    # Dispatch tasks to the OS to be ran, and pipe output and progress tracking for all tasks to STDOUT.
    #
    # @param [Array<Blueprint::Task>] tasks The tasks to run.
    #
    # @return [Hash<String, String] Task run statistics (failures, failure count, number of tasks ran).
    def dispatch_tasks(tasks)
      failures = []

      tasks.each do |task|
        cmd_spinner = TTY::Spinner.new("[:spinner] #{@pastel.decorate(task.name, task.color.to_sym)}", format: :spin)
        cmd_spinner.log("#{@pastel.decorate(task.name, task.color.to_sym)}: #{task.command}")

        cmd_spinner.run do |spinner|
          cmd = TTY::Command.new do |out, err|
            spinner << out if out
            spinner << err if err
          end

          if cmd.run!(task.command).failure?
            failures << task.id
            spinner.error('(fail)')
          else
            spinner.success('(success)')
          end # end failure check if
        end # end spinner block
      end # end task block

      {
        failures: failures,
        failure_count: failures.length,
        task_count: tasks.length
      }
    end
  end
end
