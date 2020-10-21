// MARK: - Lens

func *^ <Root, Value>(
  root: Root,
  keyPath: KeyPath<Root, Value>
) -> Value {
  root[keyPath: keyPath]
}

func *< <Root, Value>(
  writableKeyPath: WritableKeyPath<Root, Value>,
  value: Value
) -> (Root) -> Root {
  writableKeyPath.lens().set(value)
}

prefix func ^ <Root,Value> (
  writableKeyPath: WritableKeyPath<Root,Value>
) -> Lens<Root,Value> {
  writableKeyPath.lens()
}

extension WritableKeyPath {
  func lens() -> Lens<Root,Value> {
    Lens<Root,Value>.init(
      get: { $0[keyPath: self] },
      set: { part in
        { whole in
          var m = whole
          m[keyPath: self] = part
          return m
        }
    })
  }
}
