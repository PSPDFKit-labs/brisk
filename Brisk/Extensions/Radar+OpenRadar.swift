import Sonar

public enum OpenRadarParsingError: Error {
    case noResult
    case missingRequiredFields
}

public extension Radar {
    public init(openRadar json: [String: Any]) throws {
        guard let dictionary = json["result"] as? [String: Any] else {
            throw OpenRadarParsingError.noResult
        }

        let json = dictionary.onlyStrings().filterEmpty()
        guard let title = json["title"], let description = json["description"] else {
            throw OpenRadarParsingError.missingRequiredFields
        }

        let classificationString = json["classification"]?.lowercased()
        let classification = Classification.All.first { $0.name.lowercased() == classificationString }
            ?? Classification.All.first!
        let productString = json["product"]?.lowercased()
        let product = Product.All.first { $0.name.lowercased() == productString } ?? Product.All.first!

        let reproducibilityString = json["reproducible"]?.lowercased()
        let reproducibility = Reproducibility.All.first { $0.name.lowercased() == reproducibilityString }
            ?? Reproducibility.All.first!

        // Pick the last area (if there are any for the product) instead of defaulting to the first one from
        // the UI. Ideally we just wouldn't pick one in this case
        let area = Area.areas(for: product).last

        let radarID = json["number"]
        let updatedDescription = radarID.map { "This is a duplicate of radar #\($0)\n\n\(description)" }
            ?? description
        let version = json["product_version"] ?? " "

        self.init(classification: classification, product: product, reproducibility: reproducibility,
                  title: title, description: updatedDescription, steps: " ", expected: " ", actual: " ",
                  configuration: version, version: version, notes: " ", attachments: [], area: area)
    }
}
