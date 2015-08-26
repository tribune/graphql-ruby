require 'spec_helper'

describe "GraphQL::Introspection::INTROSPECTION_QUERY" do
  let(:query_string) { GraphQL::Introspection::INTROSPECTION_QUERY }
  let(:result) { GraphQL::Query.new(DummySchema, query_string, validate: false).result }

  it 'runs' do
    profiles = {
      "wall-time" => RubyProf::WALL_TIME,
      "process-time" => RubyProf::PROCESS_TIME,
      "cpu-time" => RubyProf::CPU_TIME,
      "allocations" => RubyProf::ALLOCATIONS,
      "memory" => RubyProf::MEMORY,
      "gc-time" => RubyProf::GC_TIME,
      "gc-runs" => RubyProf::GC_RUNS,
    }

    profiles.each do |name, mode|
      RubyProf.measure_mode = mode

      profile = RubyProf.profile do
        query = GraphQL::Query.new(DummySchema, query_string, validate: false)
        query.result
      end

      printer = RubyProf::FlatPrinter.new(profile)
      File.open("profile-#{name}", "wb") do  |f|
        printer.print(f)
      end
    end

    assert(result["data"])
  end
end
