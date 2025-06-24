import Foundation

import Logging

import Testing

@testable import Diss

@Suite(.serialized) class DissTests {

  @Test func testDissBindSuccess() {
    do {
      try dissSetBind(type: Service.self) { ServiceImpl() }
    } catch {
      print(error)
    }

    @DissGet
    var service: Service?
    #expect(service?.number == 1)
  }

  @Test func testDissBindFailure() {
    #expect(
      throws: DissError.multipleSet(type: "UseCase"),
      performing: {
        try dissSetBind(type: UseCase.self) { UseCase1() }
        try dissSetBind(type: UseCase.self) { UseCase2() }
      }
    )
  }

  @Test func testSingletonSuccess() {
    do {
      try dissSetSingleton { Converter.init(number: 2.12345) }
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
      performing: { try dissSetSingleton { BadSingleton() } }
    )
  }

  deinit {
    dissReset()
  }

}
class ServiceImpl: Service {
  var number: Int
  init() {
    number = 1
  }
}
protocol Service {
  var number: Int { get }
}
class Converter {
  var number: Double

  init(number: Double) {
    self.number = number
  }

  func convert() -> Double {
    return Double(round(1000 * number) / 1000)
  }
}
struct BadSingleton {}
protocol UseCase {}
struct UseCase1: UseCase {}
struct UseCase2: UseCase {}
