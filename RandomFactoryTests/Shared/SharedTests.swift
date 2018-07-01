import XCTest
import RandomFactory
import CodableExtensions
import RuntimeExtensions
import SwiftTestUtils

#if !os(Linux)
import CoreLocation
#endif

class SharedTests: BaseTestCase {
	//MARK: Linux Testing
	static var allTests = [
		("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
		("testRandomFactory", testRandomFactory)
	]

	func testLinuxTestSuiteIncludesAllTests(){
		assertLinuxTestCoverage(tests: type(of: self).allTests)
	}

	func testRandomFactory() throws {
		let count = 5
		let users: [User] = try RandomFactory.shared.randomizedArray(of: count)
		XCTAssertEqual(users.count, count)
//		for user in users{
//			try user.toAnyDictionary().printPrettyJSONString()
//		}
	}
}

open class User: Codable{
	public var name: Name
	public var username: String
	public var email: String
	public var jobTitle: String
	public var birthday: Date
	public var company: Company
	public var phoneNumber: String
	public var profileImageURL: URL
}

public struct Location: Codable{
	#if !os(Linux)
	var coordinate: CLLocationCoordinate2D
	#endif
	var thoroughfare: String
	var subThoroughfare: String
	var locality: String
	var subLocality: String
	var administrativeArea: String
	var subAdministrativeArea: String
	var postalCode: String
	var countryCode: String

}
public class Name: Codable{
	public var namePrefix: String
	public var givenName: String
	public var middleName: String
	public var familyName: String
	public var nameSuffix: String?
	public var nickname: String?
}

open class Company: Codable{
	public var name: String
	public var industry: String
	public var foundedOn: Date
	public var location: Location
	public var logoURL: URL
	public var products: [Product]
}

open class Product: Codable{
	public var name: String
	public var price: Int
	public var description: String
	public var image: URL
}

#if !os(Linux)
extension CLLocationCoordinate2D: ReflectionCodable{

	public init(from decoder: Decoder) throws {
		self.init()
		try decodeReflectively(from: decoder)
	}
}
#endif

