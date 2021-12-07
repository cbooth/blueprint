# frozen_string_literal: true

module Blueprint
  # Error handlers
  module ErrorHandlers
    # Exit on error
    EXIT = 0

    # Ignore on error
    IGNORE = 1

    # Run a shell command on error
    COMMAND = 2

    # Run a task on error
    TASK = 3
  end
end
