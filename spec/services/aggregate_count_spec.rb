require 'rails_helper'

RSpec.describe Services::AggregateCount do
  include LibHelper

  let(:project) { FactoryGirl.create(:project) }
  let(:event_name) { 'commits' }
  let(:data) {
    [
      { author: 'angdev', changes: 2 },
      { author: 'angdev', changes: 3 },
      { author: 'hello', changes: 4 }
    ]
  }

  let!(:database) { project.repository }
  let!(:collection) { database[event_name] }

  before :each do
    insert_documents(project, event_name, data)
  end

  after :each do
    clear_repository(project)
  end

  it 'forwards result from aggregation library' do
    result = Services::AggregateCount.new(project, event_name).execute
    expect(result.success?).to be true
    expect(result.value).to eq(3)

    result = Services::AggregateCount.new(project, event_name).execute(group_by: 'author')
    expect(result.success?).to be true
    expect(result.value).to match_array([
      { 'author' => 'angdev', 'result' => 2 },
      { 'author' => 'hello', 'result' => 1}
    ])
  end
end