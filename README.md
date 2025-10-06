# TinyRequest

TinyRequest is a handy Swift package of doing networking request, in a declarative way with [Combine](https://developer.apple.com/documentation/combine) and chainning style.  

## How to add TinyRequest package to an Xcode project 
1. On the Xcode top menu, go to ```File -> Add Packages```
2. Enter this for searching package URL https://github.com/frodoman/TinyRequest 
3. Select the version for the package, using the latest version is highly recommanded. Please refer to [Releases](https://github.com/frodoman/TinyRequest/releases) for the latest release version


## Sample codes

### Getting a decodable oject from a URL - Async/Await

```
let users = try? await TinyRequest(url: URL(string: "https://www.some-url.com")!)
                            .set(method: "GET")
                            .set(header: ["token": "xxx"])
                            .set(body: Data())
                            .asyncObject(type: UserAccount.self)
```

### Getting data from a URL - Async/Await

```
let (data, response) = try await TinyRequest(url: URL(string: "https://www.some-url.com")!)
                                    .set(method: "POST")
                                    .set(header: ["token":"xxx"])
                                    .set(body: Data())
                                    .asyncDataResponse()
```

### Getting a decodable oject from a URL - Combine

```
TinyRequest(url: URL(string: "https://www.some-url.com")!)
    .set(method: "GET")
    .set(header: ["token":"xxx"])
    .set(body: Data())
    .objectPublisher(type: UserAccount.self)
    .sink { completion in
        // handle completion
        
    } receiveValue: { userAccount in
        // Do something
        print("Account name is: \(userAccount.firstName) \(userAccount.lastName)")
    }
    
struct UserAccount: Decodable {
        let firstName: String
        let lastName: String
        let userId: String
}
```

### Getting data from a URL - Combine

```
TinyRequest(url: URL(string: "https://www.some-url.com")!)
    .set(method: "POST")
    .set(header: ["token":"xxx"])
    .set(body: Data())
    .dataPublisher()
    .sink { completion in
        // handle completion
        
    } receiveValue: { data in
        // Do something with the data object
    }
```

### Initialising ```TinyRequest``` with more options

```
let request = TinyRequest(request: URLRequest(url: URL(string: "xxx")!),
                          session: URLSession(configuration: /* */)
                          decoder: JSONDecoder())
```

### For a group of API requests, please confirm to `TinyServiceProtocol`
 
### Let's say we have the following API documents 
 
#### API 1: Get a file object from backend

- Host: ```https://www.some-fake-cloud-file-storage.com```
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
  {
    "contentType": "image/jpg",
    "id": "file-item-id-3",
    "isDir": false,
    "modificationDate": "2022-11-05 09:51 CET",
    "name": "picture-3.jpg",
    "parentId": "file-item-id-2",
    "size": 200000
  }
```

#### API 2: Delete a file and associated object in backend

- Host: ```https://www.some-fake-cloud-file-storage.com```
- Method: ```DELETE``` 
- Path:   ```items/{id}``` (where ```id``` is a ```String``` type)
- URI Parameters: None 
- Response: ```204``` if sccessfully deleted  

**We can define a ```FileService``` confirming to `TinyServiceProtocol` like these:** 

```
enum FileService {
    case getItem(String)
    case deleteItem(String)
}

extension FileService: TinyServiceProtocol {
    
    public var baseUrl: String {
        "https://www.some-fake-cloud-file-storage.com"
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
    
    public var decoder: JSONDecoder {
        JSONDecoder()
    }
}

public struct FileItem: Decodable {
    public let id: String
    public var parentId: String?
    public let name: String
    public let isDir: Bool
    
    public var contentType: ContentType?
    public var size: Int?
}
```

#### Then we can then use ```FileService``` in a ```ViewModel```: 


#### By using Async/Await

```
import TinyRequest

class ViewModel {
     
    func getFile(itemId: String) async {
    
        let fileItems = try? await FileService.getItem(itemId)
                                              .asyncObject(type: FileItem.self)
        // Do something with fileItems
    }

    func deleteFile(itemId: String) async {
    
        let (_, response) = try? await FileService.deleteItem(itemId)
                                                  .asyncDataResponse()
        
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode == 204 {
           // Delete successfully
        }
    }   
}
```


#### By using Combine

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
