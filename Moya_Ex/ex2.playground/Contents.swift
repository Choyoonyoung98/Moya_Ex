import Moya

//1) enum 선언
//2) 사용될 target 작성
enum JokesAPI {
    case randomJokes(_ firstName: String? = nil, _ lastName: String? = nil)
}

extension JokesAPI: TargetType {
    //서버 endpoint 도메인
    var baseURL: URL {
        return URL(string: "https://api.icndb.com")!
    }
    
    //도메인 뒤에 추가될 각 경로
    var path: String {
        switch self {
        case .randomJokes(_, _):
            return "/jokes/random"
        }
    }
    
    //HTTP method - GET, POST, DELET, PUT, PATCH(하나만? 일부만 변경하고 싶을 경우에)
    var method: Moya.Method {
        switch self {
        case .randomJokes(_, _):
            return .get
        }
    }
    
    var sampleData: Data {
        switch self {
        case .randomJokes(let firstName, let lastName):
            let firstName = firstName
            let lastName = lastName
            
            return Data(
                 """
        {
            "type": "success",
            "value": {
                "id": 107,
                "joke": "\(firstName ?? "")\(lastName ?? "") can retrieve anything from /dev/null."
            }
        }
        """.utf8
            )
        }
    }
    
    var task: Task {
        switch self {
        case .randomJokes(let firstName, let lastName):
            let params: [String: Any] = [
                "firstName": firstName!,
                "lastName": lastName!
            ]
            
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
            return ["Content-type": "application/json"]
    }
}

/*
 JSON response
 {
     "type": "success",
     "value": {
          "id": 268,
          "joke": "Time waits for no man. Unless that man is John Doe."
     }
 }
 */

struct Joke: Codable {
    var type: String
    var value: Value

    struct Value: Codable {
        var id: Int
        var joke: String
    }
}

let provider = MoyaProvider<JokesAPI>()
provider.request(.randomJokes("GilDong", "Hong")) { (result) in
    switch result {
    case let .success(response):
        let result = try? response.map(Joke.self)
        if let joke = result?.value.joke {
            print(joke)
        }
    case let .failure(error):
        print(error.localizedDescription)
    }
}
