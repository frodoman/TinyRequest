# TinyRequest

Tiny Request is a easy and handy way of doing networking request with Swift. 

## How to add TinyRequest package to an Xcode project 
1. On the Xcode top menu, go to File -> Add Packages
2. Enter this for searching package URL https://github.com/frodoman/TinyRequest 
3. Select the version for the package, using the latest version is highly recommanded. Please refer to https://github.com/frodoman/TinyRequest/releases for the latest release version
4. That's done!

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
```

### Getting a response from a URL 

```
    TinyRequest(url: URL(string: "https://www.some-url.com")!)
        .set(method: "GET")
        .set(header: ["token":"xxx"])
        .set(body: Data())
        .responsePublisher()
```
