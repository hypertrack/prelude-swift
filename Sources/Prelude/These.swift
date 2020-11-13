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
  enum CodingKeys: CodingKey {
    case this, that, both
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let key = container.allKeys.first
    
    switch key {
    case .none:
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: container.codingPath,
          debugDescription: "Unable to decode These"
        )
      )
    case .some(.this):
      let a = try container.decode(A.self, forKey: .this)
      self = .this(a)
    case .some(.that):
      let b = try container.decode(B.self, forKey: .that)
      self = .that(b)
    case .some(.both):
      var nestedContainer = try container.nestedUnkeyedContainer(forKey: .both)
      let a = try nestedContainer.decode(A.self)
      let b = try nestedContainer.decode(B.self)
      self = .both(a, b)
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    switch self {
    case let .this(a):
      try container.encode(a, forKey: .this)
    case let .that(b):
      try container.encode(b, forKey: .that)
    case let .both(a, b):
      var nestedContainer = container.nestedUnkeyedContainer(forKey: .both)
      try nestedContainer.encode(a)
      try nestedContainer.encode(b)
    }
  }
}

// MARK: - Hashable

extension These: Hashable where A: Hashable, B: Hashable {}
