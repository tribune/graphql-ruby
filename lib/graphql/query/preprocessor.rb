module GraphQL
  class Query
    # There might be some optimizations you could make to the document before execution
    # - Try taking fragment definitions and inserting them where
    #   their spreads are.
    #
    class Preprocessor
      attr_reader :query, :document
      def initialize(query, document)
        @query = query
        @document = document
      end

      def process
        visitor = GraphQL::Language::Visitor.new
        visitor[GraphQL::Language::Nodes::Field] << -> (node, parent) {
          node.selections.each_with_index do |selection, idx|
            if selection.is_a?(GraphQL::Language::Nodes::FragmentSpread)
              convert_to_inline_fragment(query, node, selection, idx)
            end
          end
        }

        visitor.visit(@document)
      end

      private

      # Take a fragment spread and convert it to an inline fragment
      def convert_to_inline_fragment(query, ast_node, selection, idx)
        fragment_def = query.fragments[selection.name]
        inline_fragment = GraphQL::Language::Nodes::InlineFragment.new(
          type: fragment_def.type,
           # TODO: how are these supposed to be merged?
          directives: fragment_def.directives + selection.directives,
          selections: fragment_def.selections,
        )
        ast_node.selections[idx] = inline_fragment
      end
    end
  end
end
