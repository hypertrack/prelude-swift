struct PrismM<S, T, A, B> {
  private let _extract: (S) -> A?
  private let _embed: (B) -> T
  
  init(extract: @escaping (S) -> A?, embed: @escaping (B) -> T) {
    self._extract = extract
    self._embed = embed
  }
  
  func extract(from root: S) -> A? { _extract(root) }
  func embed(_ value: B) -> T { _embed(value) }
}

typealias Prism<Root, Value> = PrismM<Root, Root, Value, Value>

extension PrismM where S == T, A == B {
  typealias Root = S
  typealias Value = A
}

extension PrismM {
  func tryModify(_ f: @escaping (A) -> B) -> (S) -> T? {
    extract >>> map(f >>> embed)
  }
  
  func appending<C, D>(_ prism: PrismM<A, B, C, D>) -> PrismM<S, T, C, D> {
    PrismM<S, T, C, D>(
      extract: extract >=> prism.extract,
      embed: prism.embed >>> embed
    )
  }
}

// MARK: - Operators

func *^? <S, T, A, B>(
  root: S,
  prism: PrismM<S, T, A, B>
) -> A? {
  prism.extract(from: root)
}

func *< <S, T, A, B>(
  prism: PrismM<S, T, A, B>,
  value: B
) -> (S) -> T {
  prism.embed(value) |> constant
}

func *~? <S, T, A, B>(
  prism: PrismM<S, T, A, B>,
  f: @escaping (A) -> B
) -> (S) -> T? {
  prism.tryModify(f)
}

func ** <S, T, A, B, C, D> (
  left: PrismM<S, T, A, B>,
  right: PrismM<A, B, C, D>
) -> PrismM<S, T, C, D> {
  left.appending(right)
}

prefix func / <Root, Value>(
  embed: @escaping (Value) -> Root
) -> Prism<Root, Value> {
  .case(embed)
}

prefix func / <Root>(
  root: Root
) -> Prism<Root, Void> {
  .case(root)
}

prefix func / <Root>(
  type: Root.Type
) -> Prism<Root, Root> {
  .self
}

prefix func / <Root, Value>(
  case: @escaping (Value) -> Root
) -> (Root) -> Value? {
  extract(`case`)
}

prefix func / <Root>(
  root: Root
) -> (Root) -> Void? {
  (/root).extract
}

// MARK: - Types
extension Optional {
  static var prism: Prism<Optional, Wrapped> {
    Prism<Optional, Wrapped>(
      extract: identity,
      embed: Optional.some
    )
  }
}

extension Prism where S == T, A == B, Root == Value {
  static var `self`: Prism<Root, Value> {
    Prism(
      extract: Optional.some,
      embed: identity
    )
  }
}

extension Prism where S == T, A == B, Root == Void {
  static func const(value: Value) -> Prism<Root, Value> {
    Prism(
      extract: { .some(value) },
      embed: { _ in () }
    )
  }
}

extension Prism where S == T, A == B, Value == Never {
  static var never: Prism<Root, Value> {
    Prism(
      extract: constant(nil),
      embed: absurd
    )
  }
}

extension Prism where S == T, A == B, Value: RawRepresentable, Root == Value.RawValue {
  static var rawValue: Prism<Root, Value> {
    .init(
      extract: Value.init(rawValue:),
      embed: { $0.rawValue }
    )
  }
}

extension Prism where S == T, A == B, Value: LosslessStringConvertible, Root == String {
  static var description: Prism<Root, Value> {
    .init(
      extract: Value.init,
      embed: { $0.description }
    )
  }
}
