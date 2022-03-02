import UIKit
//import Moya

/*
 playground에 pod 라이브러리 설치 방법
 > sudo gem install cocoapods-playgrounds
 > pods playgrounds Moya
 
 
 */
struct Joke: Codable {
    let id: Int
    let joke: String
    let categories: [String]
}

struct JokeResponse: Codable {
    let type: String
    let value: Joke
}

enum JokesAPI {
    case randomJokes
    static let baseURL = "https://api.icndb.com"
//    var path
    var url: URL
}

enum APIError: LocalizedError {
    case unknownError
}

class JokesAPIProvider { //API에 대한 Provider 작성
    let session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchRandomJoke(completion: @escaping (Result<Joke, Error>) -> Void) {
        let request = URLRequest(url: JokesAPI.randomJokes.url)
        
        //1) dataTask(with:)를 이용해 URLSessionDataTask를 생성한 후
        //2) task.resume() 메서드를 호출해 요청을 보낸다 (cf. resume(), suspend(), cancel())
        let task: URLSessionDataTask = session.dataTask(with: request) { data, urlResponse, error in
            guard let response = urlResponse as? HTTPURLResponse,
                  (200...399).contains(response.statusCode) else {
                      completion(.failure(error ?? APIError.unknownError))
                      return
                  }
            
            if let data = data,
               let jokeResponse = try? JSONDecoder().decode(JokeResponse.self, from: data) {
                completion(.success(jokeResponse.value))
                return
            }
            completion(.failure(APIError.unknownError))
        }
        task.resume()
    }
}
