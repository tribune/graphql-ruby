require "spec_helper"

describe GraphQL::Query::Preprocessor do
  let(:result) { schema.execute(query_string)}

  describe "flattening fragments" do
    let(:schema) {
      count_all_subselections = -> (ast_node) {
        ast_node.selections.length +
          ast_node.selections.inject(0) { |memo, c| memo + count_all_subselections.call(c) }
      }
      counter_type = GraphQL::ObjectType.define do
        name "Counter"
        field :count, types.Int do
          resolve -> (o, a, c){ o }
        end

        field :a, types.String, property: :to_s
        field :b, types.String, property: :to_s
        field :c, types.String, property: :to_s
        field :counter, -> { counter_type } do
          resolve -> (obj, args, ctx) {
            count_all_subselections.call(ctx.ast_node)
          }
        end
      end
      GraphQL::Schema.new(query: counter_type)
    }

    let(:query_string) {%|
      {
        inlineCounter: counter { a, b, c, count, counter { a } }

        inlineFragmentCounter: counter {
          ...on Counter {
            a, b, count, counter {
              ... on Counter { a, b, c }
            }
          }
        }

        fragmentCounter: counter {
          ... counterFields
        }
      }

      fragment counterFields on Counter {
        a, b, c, count
      }
    |}

    it "exposes direct selections through ast_node" do
      result_count = result["data"]["inlineCounter"]["count"]
      assert_equal 6, result_count
    end

    it "exposes inline fragments through ast_node" do
      result_count = result["data"]["inlineFragmentCounter"]["count"]
      assert_equal 9, result_count
    end

    it "exposes fragment-spreaded fields through ast_node" do
      result_count = result["data"]["fragmentCounter"]["count"]
      assert_equal 5, result_count
    end
  end
end
