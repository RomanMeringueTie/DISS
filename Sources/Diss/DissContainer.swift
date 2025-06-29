import Foundation
import Logging

private let logger = Logger(label: "diss")

internal class DissContainer {
  internal static let instance = DissContainer()
  private var instances: [ObjectIdentifier: Any] = [ObjectIdentifier: Any]()
  private var uniques: [ObjectIdentifier: () -> Any] = [ObjectIdentifier: () -> Any]()
  private var factories: [ObjectIdentifier: () -> Any] = [ObjectIdentifier: () -> Any]()
  internal var assists: [ObjectIdentifier: ([Any]) throws -> Any] = [ObjectIdentifier: ([Any]) throws -> Any]()

  private init() {}

  internal func addInstance<T>(type: T.Type, object: T) throws {
    let key = ObjectIdentifier(type)
    guard getByType(T.self) == nil else {
      throw DissError.multipleSet(type: "\(T.self)")
    }
    instances[key] = object
  }

  internal func addUnique<T>(type: T.Type, initializer: @escaping () -> T) throws {
    let key = ObjectIdentifier(type)
    guard getByType(T.self) == nil else {
      throw DissError.multipleSet(type: "\(T.self)")
    }
    uniques[key] = initializer
  }

  internal func addFactory<T>(type: T.Type, initializer: @escaping () -> T) throws {
    let key = ObjectIdentifier(type)
    guard getByType(T.self) == nil else {
      throw DissError.multipleSet(type: "\(T.self)")
    }
    factories[key] = initializer
  }

  internal func addAssist<T>(type: T.Type, initializer: @escaping (Any) -> T) throws {
    let key = ObjectIdentifier(type)
    guard getByType(T.self) == nil else {
      throw DissError.multipleSet(type: "\(type)")
    }
    assists[key] = initializer
  }

  internal func getByType<T>(_ type: T.Type) -> T? {
    let key = ObjectIdentifier(type)
    logger.debug("TYPE in getByType: '\(key)'")
    let findedObject: T? = getSingleton(key) ?? getFactory(key) ?? getUnique(key)
    return findedObject
  }

  internal func getAssist<T>(_ type: T.Type, _ arguments: [Any]) -> T? {
    let key = ObjectIdentifier(type)
    let findedObject: T?
    do {
     try findedObject = assists[key]?(arguments) as? T
    } catch {
      logger.error("Typecast error: \(error)")
      findedObject = nil
    }
    logger.debug("Finded in assists: \(String(describing: findedObject))")
    return findedObject
  }

  private func getSingleton<T>(_ key: ObjectIdentifier) -> T? {
    let findedObject = instances[key] as? T
    logger.debug("Finded in instances: \(String(describing: findedObject))")
    return findedObject
  }

  private func getUnique<T>(_ key: ObjectIdentifier) -> T? {
    let findedObject = uniques[key]?() as? T
    if findedObject != nil {
      logger.debug("Scope object created: \(String(describing: findedObject!))")
    }
    return findedObject
  }

  private func getFactory<T>(_ key: ObjectIdentifier) -> T? {
    let findedObject = factories[key]?() as? T
    if findedObject != nil {
      logger.debug("Factory object created: \(String(describing: findedObject!))")
      instances[key] = findedObject
    }
    return findedObject
  }

  internal func reset() {
    instances.removeAll()
    uniques.removeAll()
    factories.removeAll()
    assists.removeAll()
  }

  deinit {
    logger.debug("DissContainer destroyed")
  }
}

extension DissContainer: @unchecked Sendable {}

internal func dissReset() {
  DissContainer.instance.reset()
}

internal enum DissError: Error, Equatable {
  case structSingleton
  case multipleSet(type: String)
  case assistedNotUnique
  case unexpectedType(expected: String, actual: String)
}
