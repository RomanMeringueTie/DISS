import Foundation

import Logging

import Testing

@testable import Diss

@Suite(.serialized) class DissTests {

  @Test func testDissBindSuccess() {
    do {
      try DissSetBind(type: Service.self) { ServiceImpl() }
    } catch {
      print(error)
    }

    @DissGet
    var service: Service?
    #expect(service?.n == 1)
  }

  @Test func testDissBindFailure() {
    #expect(
      throws: DissError.multipleSet(type: "UseCase"),
      performing: {
        try DissSetBind(type: UseCase.self) { UseCase1() }
        try DissSetBind(type: UseCase.self) { UseCase2() }
      }
    )
  }

  @Test func testSingletonSuccess() {
    do {
      try DissSetSingleton { Converter.init(n: 2.12345) }
    } catch {
      print(error)
    }

    @DissGet
    var converter: Converter?
    #expect(converter?.convert() == 2.123)
  }

  @Test func testSingletonFailure() {
    #expect(
      throws: DissError.structSingleton,
      performing: { try DissSetSingleton { BadSingleton() } }
    )
  }

  deinit {
    DissReset()
  }

}
class ServiceImpl: Service {
  var n: Int
  init() {
    n = 1
  }
}
protocol Service {
  var n: Int { get }
}
class Converter {
  var n: Double

  init(n: Double) {
    self.n = n
  }

  func convert() -> Double {
    return Double(round(1000 * n) / 1000)
  }
}
struct BadSingleton {}
class A {}
protocol UseCase {}
struct UseCase1: UseCase {}
struct UseCase2: UseCase {}
