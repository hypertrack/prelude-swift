struct LensM<S, T, A, B> {
  private let _get: (S) -> A
  private let _set: (B) -> (S) -> T
  
  init(get: @escaping (S) -> A, set: @escaping (B) -> (S) -> T) {
    self._get = get
    self._set = set
  }
  
  func get(from root: S) -> A { _get(root) }
  func set(_ value: B) -> (S) -> T { _set(value) }
}

typealias Lens<Root, Value> = LensM<Root, Root, Value, Value>

extension LensM where S == T, A == B {
  typealias Root = S
  typealias Value = A
}

extension LensM {
  func modify(_ f: @escaping (A) -> B) -> (S) -> T {
    get >>> f >>> set |> join
  }
  
  func appending<C, D>(_ lens: LensM<A, B, C, D>) -> LensM<S, T, C, D> {
    LensM<S, T, C, D>(
      get: get >>> lens.get,
      set: { d in
        get >>> lens.set(d) >>> set |> join
      }
    )
  }
}

// MARK: - Operators

func *^ <S, T, A, B>(
  root: S,
  lens: LensM<S, T, A, B>
) -> A {
  lens.get(from: root)
}

func *< <S, T, A, B>(
  lens: LensM<S, T, A, B>,
  value: B
) -> (S) -> T {
  lens.set(value)
}

func *~ <S, T, A, B>(
  lens: LensM<S, T, A, B>,
  f: @escaping (A) -> B
) -> (S) -> T {
  lens.modify(f)
}

func ** <S, T, A, B, C, D> (
  left: LensM<S, T, A, B>,
  right: LensM<A, B, C, D>
) -> LensM<S, T, C, D> {
  left.appending(right)
}

// MARK: - Laws

enum LensLaw {
  static func setGet <Root, Value> (lens: Lens<Root, Value>, root: Root, value: Value) -> Bool where Value: Equatable {
    lens.get(from: lens.set(value)(root)) == value
  }

  static func setGet <Root, X, Y> (lens: Lens<Root, (X, Y)>, root: Root, value: (X, Y)) -> Bool where X: Equatable, Y: Equatable {
    lens.get(from: lens.set(value)(root)) == value
  }

  static func getSet <S,A> (lens: Lens<S,A>, root: S) -> Bool where S: Equatable {
    lens.set(lens.get(from: root))(root) == root
  }

  static func setSet <S,A> (lens: Lens<S,A>, root: S, value: A) -> Bool where S: Equatable {
    lens.set(value)(root) == lens.set(value)(lens.set(value)(root))
  }
}
