# SwipeActions-MacOS

Just add the macOS support for [`SwipeActions`](https://github.com/aheze/SwipeActions)

Support macOS(v11.0, *)


### Installation
SwipeActions-MacOS can be installed with the Swift Package Manager:

```
https://github.com/Lorpaves/SwipeActions-MacOS.git
```

### Using SwipeView

```swift
import SwipeActions-MacOS

SwipeView {
    Text("Hello World!")
} leadingActions: { _ in
    SwipeAction("...") {
        // ...
    }
}

```

Detailed Usage: see [`SwipeActions`](https://github.com/aheze/SwipeActions)

