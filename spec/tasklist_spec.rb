# frozen_string_literal: true

require 'spec_helper'

require 'blueprint/task'
require 'blueprint/tasklist'
require 'blueprint/errors'

RSpec.describe Blueprint::Tasklist do
  describe '.new' do
    context 'with a valid tasklist spec file' do
      it 'loads spec metadata' do
        bp = Blueprint::Tasklist.new "#{RSPEC_ROOT}/resources/valid.blueprint"
        expect(bp).to have_attributes(
          name: 'Valid',
          task_count: 2
        )
      end

      it 'loads fully spec\'d tasks' do
        bp = Blueprint::Tasklist.new "#{RSPEC_ROOT}/resources/valid.blueprint"

        expect(bp.tasks[0]).to have_attributes(
          id: 'task1',
          command: 'null1',
          name: 'Task1Name',
          description: 'Task1Description',
          color: 'green',
          error: 'ignore'
        )
      end

      it 'assigns default values to partially spec\'d tasks' do
        bp = Blueprint::Tasklist.new "#{RSPEC_ROOT}/resources/valid.blueprint"
        
        expect(bp.tasks[1]).to have_attributes(
          id: 'task2',
          command: 'null2',
          name: 'null2',
          description: '',
          color: 'blue',
          error: nil
        )
      end
    end

    context 'with a malformed tasklist spec file' do
      it 'throws Blueprint::ValidationError' do
        expect do
          Blueprint::Tasklist.new "#{RSPEC_ROOT}/resources/malformed.blueprint"
        end.to raise_error(Blueprint::ValidationError)
      end
    end
  end

  describe '.constrain' do
    it 'truncates the beginning of the tasklist when given a \'from\' parameter' do
      bp = Blueprint::Tasklist.new "#{RSPEC_ROOT}/resources/constraints.blueprint"
      constraints = bp.constrain(from: 'task2')
      expect(constraints.map(&:id)).to eq %w[task2 task3 task4 task5 task6 task7]
    end

    it 'truncates the end of the tasklist when given a \'to\' parameter' do
      bp = Blueprint::Tasklist.new "#{RSPEC_ROOT}/resources/constraints.blueprint"
      constraints = bp.constrain(to: 'task5')
      expect(constraints.map(&:id)).to eq %w[task1 task2 task3 task4 task5]
    end

    it 'restricts the tasklist to a range when given a \'from\' and \'to\' parameter' do
      bp = Blueprint::Tasklist.new "#{RSPEC_ROOT}/resources/constraints.blueprint"
      constraints = bp.constrain(from: 'task2', to: 'task5')
      expect(constraints.map(&:id)).to eq %w[task2 task3 task4 task5]
    end

    it 'takes a subset of the tasklist in file order when given a \'tasks\' parameter' do
      bp = Blueprint::Tasklist.new "#{RSPEC_ROOT}/resources/constraints.blueprint"
      constraints = bp.constrain(tasks: %w[task5 task1 task7])
      expect(constraints.map(&:id)).to eq %w[task1 task5 task7]
    end

    it 'returns the entire tasklist when given no parameters' do
      bp = Blueprint::Tasklist.new "#{RSPEC_ROOT}/resources/constraints.blueprint"
      constraints = bp.constrain
      expect(constraints.map(&:id)).to eq %w[task1 task2 task3 task4 task5 task6 task7]
    end

    it 'throws Blueprint::InvalidTaskError when given an invalid task ID as the from parameter' do
      bp = Blueprint::Tasklist.new "#{RSPEC_ROOT}/resources/constraints.blueprint"
      expect { bp.constrain(from: 'task0') }.to raise_error(Blueprint::InvalidTaskError)
    end

    it 'throws Blueprint::InvalidTaskError when given an invalid task ID as the to parameter' do
      bp = Blueprint::Tasklist.new "#{RSPEC_ROOT}/resources/constraints.blueprint"
      expect { bp.constrain(to: 'task8') }.to raise_error(Blueprint::InvalidTaskError)
    end

    it 'throws Blueprint::InvalidTaskError when given an invalid task ID in the tasks parameter' do
      bp = Blueprint::Tasklist.new "#{RSPEC_ROOT}/resources/constraints.blueprint"
      expect { bp.constrain(tasks: %w[task1 task5 task9]) }.to raise_error(Blueprint::InvalidTaskError)
    end

    it 'follows the constraint precendence and returns a subset of the tasklist in file order when given all parameters (ignores \'from\'/\'to\' in favour of \'tasks\')' do
      bp = Blueprint::Tasklist.new "#{RSPEC_ROOT}/resources/constraints.blueprint"
      constraints = bp.constrain(from: 'task3', to: 'task5', tasks: %w[task1 task2 task3 task4])
      expect(constraints.map(&:id)).to eq %w[task1 task2 task3 task4]
    end
  end

  describe '.valid_id?' do
    it 'is true for a valid id' do
      bp = Blueprint::Tasklist.new "#{RSPEC_ROOT}/resources/constraints.blueprint"
      expect(bp.send(:valid_id?, 'task1')).to be true
    end

    it 'is false for an invalid id' do
      bp = Blueprint::Tasklist.new "#{RSPEC_ROOT}/resources/constraints.blueprint"
      expect(bp.send(:valid_id?, 'taskA')).to be false
    end

    it 'is false for an empty or nil argument' do
      bp = Blueprint::Tasklist.new "#{RSPEC_ROOT}/resources/constraints.blueprint"
      expect(bp.send(:valid_id?, '')).to be false
      expect(bp.send(:valid_id?, nil)).to be false
    end
  end
end
