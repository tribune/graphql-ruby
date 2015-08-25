require 'spec_helper'

describe "GraphQL::Introspection::INTROSPECTION_QUERY" do
  let(:query_string) { GraphQL::Introspection::INTROSPECTION_QUERY }
  let(:result) { GraphQL::Query.new(DummySchema, query_string, validate: false).result }

  it 'runs' do

    # RubyProf.measure_mode = RubyProf::WALL_TIME
    # RubyProf.measure_mode = RubyProf::PROCESS_TIME
    # RubyProf.measure_mode = RubyProf::CPU_TIME
    # RubyProf.measure_mode = RubyProf::ALLOCATIONS
    # RubyProf.measure_mode = RubyProf::MEMORY
    # RubyProf.measure_mode = RubyProf::GC_TIME
    # RubyProf.measure_mode = RubyProf::GC_RUNS

    profile = RubyProf.profile do
      result
    end

    printer = RubyProf::FlatPrinter.new(profile)
    File.open("profile", "wb") do  |f|
      printer.print(f)
    end

    assert(result["data"])
  end
end
