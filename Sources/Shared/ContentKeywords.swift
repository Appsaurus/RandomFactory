//
//  ContentKeywords.swift
//  RandomFactory
//
//  Created by Brian Strobach on 6/1/18.
//

import Foundation
import RuntimeExtensions

//Workaround to enforce RawValue type in where clause since Non-protocol, non-class type 'String' cannot be used within a protocol-constrained type
private protocol RawString{}
extension String: RawString {}

public protocol ContentKeywordsEnum: RawRepresentable, CaseIterable where Self.RawValue: Hashable & RawString{
	static func unknownCase() -> Self
}

extension ContentKeywordsEnum{
	internal static func keywordMap() -> [String : Self]{
		return allCases.reduce(into: [String: Self]()) { dict, enumCase in
			enumCase.split.forEach({ (keyword) in
				dict[keyword] = enumCase
			})
		}
	}

	public var split: [String]{
		return "\(rawValue)".split(separator: ",").map({String($0)})
	}

	public static func closestMatch(ofString label: String, maxDistance: Int? = nil) -> Self{
		let label = label.lowercased()
		let maxDistance = maxDistance ?? Int.max
		guard let match = Self.keywordMap()[label] else {
			let levenshteinMatch = Self.maxDistance(from: label)
			guard levenshteinMatch.0 <= maxDistance else { return unknownCase() }
			return levenshteinMatch.1
		}
		return match
	}
	private static func maxDistance(from string: String) -> (Int, Self){
		let cases = Self.allCases
		var min = (Int.max, unknownCase())
		for enumCase in cases{
			let newMin = enumCase.maxDistance(from: string)
			if newMin.0 < min.0 { min = (newMin.0, enumCase) }
		}
		return min
	}
	private func maxDistance(from string: String) -> (Int, String){
		var min = (Int.max, "")
		let lev = Levenshtein()
		for keyword in self.split{
			let newMin = lev.calculateDistance(a: keyword, b: string)
			if newMin < min.0 { min = (newMin, keyword) }
		}
		return min
	}
}

public enum ParentType: String, ContentKeywordsEnum{
	//For speeding up cache when we are unable to make a good guess about content type
	public static func unknownCase() -> ParentType {
		return .unknown
	}
	case unknown
	case company = "company,business,vendor"
	case user = "user,account"
	case product = "product,sku,item"
}
public enum ContentType: String, ContentKeywordsEnum{
	//For speeding up cache when we are unable to make a good guess about content type
	public static func unknownCase() -> ContentType {
		return .unknown
	}

	case unknown
	//MARK: Location
	//Addresses
	case thoroughfare = "streetName,thoroughfare,street" //eg. Infinite Loop
	case subThoroughfare = "subthoroughfare,buildingnumber,streetnumber" //eg. 1
	case secondaryAddress = "secondaryaddress" //eg. Apt. 123
	case subLocality = "sublocality,neighborhood,landmark,commonname,district" //eg. Mission District
	case locality = "city,town,locality" //eg. Cupertino
	case subAdministrativeArea = "subadministrativearea,county,region" //eg. Santa Clara
	case administrativeArea = "state,administrativearea,province" //eg. California
	case stateAbbreviation = "stateabbreviation" //eg. CA
	case postalCode = "postalcode,postcode,zipcode,zip" // eg. 95014
	case country = "country" // eg. United States
	case ISOCountryCode = "isocountrycode,countrycode" // eg. US
	case timeZone = "timezone" //eg. America/Los_Angeles

	//Geolocation
	case latitude = "latitude,lat" // eg. -58.17256227443719
	case longitude = "longitude,long" // eg. -156.65548382095133


	//MARK: Company
	case companyName = "company,companyname,business,businessname,vendor,vendorname"

	//MARK: Contact
	case email = "email,emailaddress"
	//Phone Numbers

	//MARK: Database
	case id = "id,key,identifier,uuid"

	//MARK: People
	//Misc
	case age = "age"
	case jobTitle = "jobtitle,job,role"

	//Names
	case fullname = "fullname,displayname"
	case namePrefix = "prefix,honorific,nameprefix"
	case givenName = "givenname,firstname,first,forename"
	case familyName = "familyName,surname,lastname,last"
	case middleName = "middlename"
	case middleInitial = "middleinitial"
	case nameSuffix = "suffix,namesuffix"
	case nickname = "nickname,moniker,familiarname"

	//MARK: Internet
	case username = "username,handle,identity,userid,login,author,owner"
	case password = "password,passwordhash"
	case ipAddress = "ip,ipaddress"

	//MARK: Products
	case productName = "product,productname,itemname,item"
	case price = "price"

	//MARK: Text
	case sentence = "shortdescription,intro,tagline,shortbio"
	case paragraph = "text,content,copy,description,bio"
	case fulltext = "fulltext,longdescription,fullbio"

	//MARK: Ambiguous
	case name = "name"
	case title = "title"
	case number = "number"

	//MARK: Truthy
	case truthy = "confirmed,activated,deleted,active,available,open,closed,sent,receieved,processed,processing"

	case url = "url,web,website,webaddress"
	case imageURL = "photo,image,img,imageurl"
	case avatarImage = "avatar,avatarimageurl,avatarimage"
	case profileImage = "profileimage,profileimageurl,profilephoto"
	case logoImage = "logo,logoimage,logourl,logoimageurl"


}
