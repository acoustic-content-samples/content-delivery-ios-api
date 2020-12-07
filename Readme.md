# Acoustic iOS SDK

## How to start 

This document is intended to help to understand how to use Acoustic Content SDK in own projects.

### How to add SDK

1. Firstly add SDK to project. There are several ways how to add SDK to own projects:

    - As source code:
        - Copy `Classes` folder into your project. Rename if needed.
        - Use SDK classes directly without importing them

    - As `Xcode Project` dependency:
        - `Drag&drop` SDK XCode project to your project
        - Go to `Project settings` -> `TARGETS` -> _Your target_ -> `Build Phases`
        - Add SDK into `Dependencies` and `Link Binary With Libraries` groups

    - As part of `Xcode Workspace` in form of `Xcode Project` dependency
        - perform actions from previous list but against `Project Workspace`

    - As regular or emdedded `Framework`:
         - Build regular Framework 
         - or build Fat Framework (refer iOS SDK Fat Framework How-To document)
         - or extract framework on `XCFramework` making step from appropriate `outputs/platform_device.xcarchive` and `outputs/platform_simulator.xcarchive` files (in Finder tap _Show Package Contents_ and go to _Products->Library->Frameworks_ folder)
         - Refer `Embedding Frameworks In An App` document from list below
         - Pay attention to `Embed & Code Sign` option if needed

    - As `XCFramework`:
        - Build XCFramework (refer iOS SDK XCFramework How-To document)
        - `Drag&drop` xcframework to your project
        - Refer `Embedding Frameworks In An App` document from list below
        - Pay attention to `Embed & Code Sign` option if needed
        - Please pay attention that in your exact case XCFramework may require additional configuration or rebuilding.

        > Important: At the moment script `make_framework` contains actual iOS version for current  iOS SDK installed. You may need to update it according to your current iOS SDK installed on your workstation.

2. List of helpful links about Frameworks:
    1. [Embedding Frameworks In An App](https://developer.apple.com/library/archive/technotes/tn2435/_index.html)
    2. [Framework Programming Guide](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Frameworks.html)

3. Next step import SDK

```swift
import AcousticContentSDK
```

### How to instantiate SDK

1. Create API URL:

```swift
let url = URL(string: "https://myX.content-cms.com/api/0000-0000-0000-0000-0000")!
```

2. Create configuration for SDK:

```swift
let config = AcousticContentSDK.Config(apiURL: url)
```

3. Create SDK instance:

```swift
let sdk = AcousticContentSDK(withConfig: config)
```

### How to login

1. Use login in case SDK require accessing authenticates resources:

```swift
sdk.login(username: "username", 
          password: "password") 
{ (success, error) in
    print("Login \(success ? "succeeded" : "failed")")
}
```

2. Use logout when needed:

```swift
sdk.logout()
```

### How to run basic query

At this moment SDK is ready to retireve data.

1. Create instance of DeliverySearch class

```swift
let deliverySearch = sdk.deliverySearch()
```

2. Get artifact provider _(ex.: contentItems)_, configure request by calling `Configurable` functions:

```swift
deliverySearch.contentItems()
        .filterByName("Peru*")
        .rows(15)
        .sortBy("name", ascending: false)
        .get { (result) in
            ...
    }
```

3. Retrieve result and process it:

```swift 
.get { (result) in

    // 1. Process error
    guard result.error == nil else { return }
    
    // 2. Use data
    print("Retrieved \(result.numFound) items")
    print("Items: \(result.documents.compactMap({$0.name}).joined(separator: ", "))")
    
    // 3. Prepare next page request provider
    nextItems = result.nextPage()
}
```

4. Retrieve next page:

```swift
nextItems?.get(completion: { (result) in
    // ...
    nextItems = result.nextPage()
})
```

## How to run SDK Sample app

1. Navigate to `AcousticContentSDKSample` folder
2. Find and open `AcousticContentSDKSample.xcworkspace`

> Important: since `AcousticContentSDKSample` is organized in form of **Xcode Workspace** please pay attention that you do not need to open `AcousticContentSDKSample.xcodeproj`

3. When Xcode with sdk workspace open - navigate to `AppDelegate.swift` file
4. Find `AcousticContent` helper class and edit appropriate `baseUrl` and `tenantId`

> Important please pay attention to existing form of every constant: baseURL - it is a _domain name_ with preceding _https://_

5. Select `AcousticContentSDKSample` scheme and click `Run`.