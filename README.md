# TinyRequest

TinyRequest is a handy Swift package of doing networking request, in a declarative way with [Combine](https://developer.apple.com/documentation/combine) and chainning style.  

## How to add TinyRequest package to an Xcode project 
1. On the Xcode top menu, go to ```File -> Add Packages```
2. Enter this for searching package URL https://github.com/frodoman/TinyRequest 
3. Select the version for the package, using the latest version is highly recommanded. Please refer to [Latest Releases](https://github.com/frodoman/TinyRequest/releases) for the latest release version


## Sample codes

### Getting a decodable oject from a URL

```
struct UserAccount: Decodable {
        let firstName: String
        let lastName: String
        let userId: String
}

TinyRequest(url: URL(string: "https://www.some-url.com")!)
    .set(method: "GET")
    .set(header: ["token":"xxx"])
    .set(body: Data())
    .objectPublisher(type: UserAccount.self)
    .sink { completion in
        // handle completion
        
    } receiveValue: { userAccount in
        // Do something...
    }
```

### Getting data from a URL 

```
TinyRequest(url: URL(string: "https://www.some-url.com")!)
    .set(method: "GET")
    .set(header: ["token":"xxx"])
    .set(body: Data())
    .dataPublisher()
    .sink { completion in
        // handle completion
        
    } receiveValue: { userAccount in
        // Do something...
    }
```

### Getting a response from a URL 

```
TinyRequest(url: URL(string: "https://www.some-url.com")!)
    .set(method: "GET")
    .set(header: ["token":"xxx"])
    .set(body: Data())
    .responsePublisher()
    .sink { completion in
        // handle completion
        
    } receiveValue: { userAccount in
        // Do something...
    }
```

### Initialising ```TinyRequest``` with more arguments

```
let tiny = TinyRequest(request: URLRequest(url: URL(string: "xxx")!),
                       session: URLSession(configuration: /* */)
                       decoder: JSONDecoder())
```

### For a group of API requests, please confirm to `TinyServiceProtocol`

For example, we can define a ```FileService``` confirming to `TinyServiceProtocol` for the following API documents 

#### API 1: Get a list of file objects from backend

- Method: ```GET``` 
- Path:   ```items/{id}``` (```id``` is a ```String``` type)
- URI Parameters: None 
- Response: ```200```
   - Response headers: 
```
    Content-Type: application/json
```
   - Response body:
```
[
  {
    "id": "a8537d631d21a8b7fdbbcd11e4d2e5d09d61971d",
    "isDir": true,
    "modificationDate": "2015-11-05 09:14 CET",
    "name": "Documents",
    "parentId": "ec94bd0365b352832710f171bd8463b6d9caf6e7"
  },
  {
    "contentType": "image/jpg",
    "id": "e788eb7b65f4f16cbfac9e50cbec7c01c1fb6e61",
    "isDir": false,
    "modificationDate": "2015-11-05 09:51 CET",
    "name": "picture.jpg",
    "parentId": "ec94bd0365b352832710f171bd8463b6d9caf6e7",
    "size": 164568
  }
]
```

#### API 2: Delete a file and associated object in backend

- Method: ```DELETE``` 
- Path:   ```items/{id}``` (where ```id``` is a ```String``` type)
- URI Parameters: None 
- Response: ```204``` if sccessfully deleted  

```

public struct FileItem: Decodable {
    public let id: String
    public var parentId: String?
    public let name: String
    public let isDir: Bool
    
    public var contentType: ContentType?
    public var size: Int?
}

enum FileService {
    case getItem(String)
    case deleteItem(String)
}

extension FileService: TinyServiceProtocol {
    
    public var baseUrl: String {
        "https://www.some.host.com"
    }
    
    public var decoder: JSONDecoder {
        JSONDecoder()
    }
    
    public var urlPath: String {
        switch self {
        case .getItem(let itemId),
             .deleteItem(let itemId):
            return "/items/\(itemId)"
        }
    }
    
    public var queryItems: [URLQueryItem]? {
        nil
    }
    
    public var method: String {
        switch self {
        case .getItem:
            return "GET"
        case .deleteItem:
            return "DELETE"
        }
    }
    
    public var header: [String : String]? {
        nil
    }
    
    public var body: Data? {
        nil
    }
}
```

#### Then we can use ```FileService``` like the following in a ```ViewModel```: 

```
import TinyRequest
import Combine

class ViewModel {

    private var cancellables: [AnyCancellable] = []
     
    func getFile(itemId: String) {
    
        FileService.getItem(itemId)
            .objectPublisher(type: [FileItem].self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // TODO
                
            } receiveValue: { [weak self] items in
                // TODO
            }
            .store(in: &cancellables)
    }

    func deleteFile(itemId: String) {
    
        FileService.deleteItem(itemId)
            .responsePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // TODO
                
            } receiveValue: { [weak self] response in
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 204 {
                    // Delete successfully
                }
            }
            .store(in: &cancellables)
    }   
}
```
