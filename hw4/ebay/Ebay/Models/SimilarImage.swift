import Foundation

struct SimilarImage: Codable {
    struct Url: Codable {
        let type: String
        let template: String
    }

    struct Request: Codable {
        let title: String
        let totalResults: String
        let searchTerms: String
        let count: Int
        let startIndex: Int
        let inputEncoding: String
        let outputEncoding: String
        let safe: String
        let cx: String
        let searchType: String
        let imgSize: String
    }

    struct NextPage: Codable {
        let title: String
        let totalResults: String
        let searchTerms: String
        let count: Int
        let startIndex: Int
        let inputEncoding: String
        let outputEncoding: String
        let safe: String
        let cx: String
        let searchType: String
        let imgSize: String
    }

    struct Context: Codable {
        let title: String
    }

    struct SearchInformation: Codable {
        let searchTime: Double
        let formattedSearchTime: String
        let totalResults: String
        let formattedTotalResults: String
    }

    struct Image: Codable {
        let contextLink: String
        let height: Int
        let width: Int
        let byteSize: Int
        let thumbnailLink: String
        let thumbnailHeight: Int
        let thumbnailWidth: Int
    }

    struct Item: Codable {
        let kind: String
        let title: String
        let htmlTitle: String
        let link: String
        let displayLink: String
        let snippet: String
        let htmlSnippet: String
        let mime: String
        let fileFormat: String
        let image: Image
    }

    let kind: String
    let url: Url
    let queries: [String: [Request]]
    let context: Context
    let searchInformation: SearchInformation
    let items: [Item]
}
