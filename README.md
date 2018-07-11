# RandomFactory
![Swift](http://img.shields.io/badge/swift-4.1-orange.svg)
![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)
![License](http://img.shields.io/badge/license-MIT-CCCCCC.svg)

RandomFactory allows you to generate somewhat realistic fake data for any Codable model. Using the types and names of your model's properties, RandomFactory will make an educatd guess as to what your data should look like.

## Installation

**RandomFactory** is available through [Swift Package Manager](https://swift.org/package-manager/). To install, add the following to your Package.swift file.

```swift
let package = Package(
    name: "YourProject",
    dependencies: [
        ...
        .package(url: "https://github.com/Appsaurus/RandomFactory", from: "1.0.0"),
    ],
    targets: [
      .target(name: "YourApp", dependencies: ["RandomFactory", ... ])
      //or if just using for test purposes
      .testTarget(name: "YourAppTests", dependencies: ["RandomFactory", ... ])
    ]
)
        
```

**RandomFactory** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RandomFactory', :git => "https://github.com/Appsaurus/RandomFactory"
```

**RandomFactory** is also available through [Carthage](https://github.com/Carthage/Carthage).
To install just write into your Cartfile:

```ruby
github "Appsaurus/RandomFactory"
```

## Usage

Create your model classes (don't forget to implement Codable):

```swift
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
	var coordinate: CLLocationCoordinate2D
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
```
Then you can generate an instance like so:

```swift
let user: User = try RandomFactory.shared.randomized()
```

Which will generate the following data for our example models:

![Data](/GeneratedDataExample.png)

You may also directly instantiate your own RandomFactory without using the `shared` singleton, however, the singleton approach will give you drastic speed improvements when generating multiple instances of the same class as it caches the results of the content type matching algorithm.

### Arrays

```swift
let count = 5
let users: [User] = try RandomFactory.shared.randomizedArray(of: count)
```

## ⚠️ WARNING

This library usings runtime reflection to analyze your model and generate appropriate data. This library is probably best used for testing purposes (like seeding a bunch of test data into a database), due to swift ABI instability. I will do my best to keep this updated with new versions of Swift, but depending upon what the swift team does, this library could break in future versions of Swift. Hopefully, once ABI stability is achieved, there will be a better, more reliable way to do reflection and this will be production ready.

## Contributing

We would love you to contribute to **RandomFactory**, check the [CONTRIBUTING](github.com/Appsaurus/RandomFactory/blob/master/CONTRIBUTING.md) file for more info.

## License

**RandomFactory** is available under the MIT license. See the [LICENSE](github.com/Appsaurus/RandomFactory/blob/master/LICENSE.md) file for more info.


