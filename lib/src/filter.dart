
/// Defines the operator for a filter condition.
enum FilterOperator {
  /// Represents an equality condition (==).
  equals,
}

/// Represents a query condition to filter documents.
///
/// A [Filter] is a structured, analyzable alternative to using a
/// function predicate, which allows the query engine to perform optimizations
/// like using an index.
class Filter {
  /// The document field to which the filter applies.
  final String field;

  /// The operator for the comparison.
  final FilterOperator operator;

  /// The value to compare against.
  final dynamic value;

  /// Creates a new [Filter] instance.
  Filter(this.field, this.operator, this.value);

  /// Creates a filter for an equality condition (`field == value`).
  ///
  /// [field] - The document field to compare.
  /// [value] - The value to compare against.
  static Filter equals(String field, dynamic value) {
    return Filter(field, FilterOperator.equals, value);
  }
}
