import Foundation
import Logging

private let logger = Logger(label: "diss")
internal class DissContainer: @unchecked Sendable {
  internal static let instance = DissContainer()
  private var singletons: [Any] = []
  private var binds: [String: Any] = [String: Any]()

  private init() {}

  internal func addSingleton<T>(object: T) throws {
    let findedObject: T? = getByType()
    guard findedObject == nil else {
      throw DissError.multipleSet(type: "\(T.self)")
    }
    singletons.append(object)
  }

  internal func addBind<T>(type: T.Type, object: T) throws {
    let key: String = String("\(type)")
    let findedObject = binds[key]
    guard findedObject == nil else {
      throw DissError.multipleSet(type: "\(T.self)")
    }
    binds[key] = object
  }

  internal func getByType<T>() -> T? {
    logger.debug("TYPE in getByType: '\(T.self)'")
    var findedObject = binds["\(T.self)"] as? T
    logger.debug("Finded in binds: \(String(describing: findedObject))")
    if findedObject == nil {
      findedObject = singletons.first(where: { $0 is T }) as? T
      logger.debug("Finded in singletons: \(String(describing: findedObject))")
    }
    return findedObject
  }

  internal func reset() {
    singletons.removeAll()
    binds.removeAll()
  }

  internal func show() {
    logger.debug("binds: \(binds) singletons: \(singletons)")
  }

  deinit {
    logger.debug("DissContainer destroyed")
  }
}
internal func dissReset() {
  DissContainer.instance.reset()
}
internal func show() {
  DissContainer.instance.show()
}
internal enum DissError: Error, Equatable {
  case notFound
  case structSingleton
  case multipleSet(type: String)
}
