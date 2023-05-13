# GalleryView-iOS

## Requirements

| Platform | Minimum Swift Version | Installation
| --- | --- | --- |
| iOS 13.0+ | 5.0 | [CocoaPods](#cocoapods)

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate spoof-sense-ios into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'GalleryView'
```

## Launch GalleryView

Push spoofsense
```swift
GalleryView.push(with: Your_Navigation_Controller)
```

Present spoofsense
```swift
GalleryView.present(with: Your_Navigation_Controller, animated: true)
```


## Get result callback

```
GalleryView.resultCallBack = { [weak self] (jsonObject) -> Void in
    guard let self = self else { return }
    print("jsonObject: ", jsonObject)
}
```

Response Structure
```
["success": true, "imgData":"Image data as base64 string"]
```

## License

GalleryView-iOS is released under the MIT license. [See LICENSE](http://www.opensource.org/licenses/MIT) for details.
