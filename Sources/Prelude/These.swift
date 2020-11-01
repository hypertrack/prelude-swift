public enum These<A, B> {
  case this(A)
  case that(B)
  case both(A, B)
}

// MARK: - Equatable

extension These: Equatable where A: Equatable, B: Equatable {}

// MARK: - Comparable

extension These: Comparable where A: Comparable, B: Comparable {}

// MARK: - Codable

extension These: Codable where A: Codable, B: Codable {
  public init(from decoder: Decoder) throws {
    do {
      self = try .both(.init(from: decoder), .init(from: decoder))
    } catch {
      do {
        self = try .this(.init(from: decoder))
      } catch {
        self = try .that(.init(from: decoder))
      }
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    switch self {
    case let .this(a):
      try a.encode(to: encoder)
    case let .that(b):
      try b.encode(to: encoder)
    case let .both(a, b):
      try a.encode(to: encoder)
      try b.encode(to: encoder)
    }
  }
}

// MARK: - Hashable

extension These: Hashable where A: Hashable, B: Hashable {}
