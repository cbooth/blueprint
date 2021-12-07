# frozen_string_literal: true

require 'blueprint/task'

RSpec.describe Blueprint::Task do
  describe '.new' do
    context 'with only required parameters' do
      it 'assigns default parameters' do
        task_id = 'task'
        command = 'echo'

        task = Blueprint::Task.new(task_id, command)

        expect(task.name).to eq command
        expect(task.description).to eq ''
        expect(task.color).to eq 'blue'
        expect(task.error).to be_nil
      end
    end
  end
end
