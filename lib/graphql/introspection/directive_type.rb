GraphQL::Introspection::DirectiveType = GraphQL::ObjectType.define do
  name "__Directive"
  description "A query directive in this schema"
  field :name, !types.String, "The name of this directive"
  field :description, types.String, "The description for this type"
  field :args, field: GraphQL::Introspection::ArgumentsField
  field :locations, !types[!GraphQL::Introspection::DirectiveLocationEnum]

  field :onOperation, !types.Boolean, "Does this directive apply to operations?" do
    resolve ->(*) { false }
  end
  field :onFragment, !types.Boolean, "Does this directive apply to fragments?" do
    # Not sure if this the correct constant
    resolve ->(obj, *) { obj.locations.include? GraphQL::Directive::FRAGMENT_DEFINITION }
  end
  field :onField, !types.Boolean, "Does this directive apply to fields?" do
    resolve ->(obj, *) { obj.locations.include? GraphQL::Directive::FIELD }
  end
end
