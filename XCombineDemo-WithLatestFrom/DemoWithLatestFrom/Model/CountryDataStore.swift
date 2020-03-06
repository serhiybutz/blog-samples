import Foundation

struct CountryDataStore {
    // MARK: - Properties

    let allCountries: [Country]

    // MARK: - Initialization

    static func load() -> CountryDataStore {
        let path = Bundle.main.path(forResource: "CountryDataStore", ofType: "plist")!
        let data = FileManager.default.contents(atPath: path)!
        let decoder = PropertyListDecoder()
        return CountryDataStore(allCountries: try! decoder.decode([Country].self, from: data))
    }
}
