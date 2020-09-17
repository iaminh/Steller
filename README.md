# Stellar iOS app
### Trending Repositories:

## Architecture
**MVVM** with **Coordinators** in combination with reactive programming using **RxSwift**

### MVVM

We use the UIViewControllers (VCs) as the “View” tier, VCs receive necessary data from ViewModel (VM) and present them in way that they are supposed to be displayed. ViewModel handles all business logic - data transformations, connection to services (Networking, CoreData, etc...). We are trying to keep those classes as much lightweight as possible, so all logic that is not connected directly to functionality of that screen should be kept outside - e.g. you should not keep your call to REST API in ViewModel, you will create a service that handles all networking (or at least a subset of it - depends on the scale) and your VM will communicate only with that service. Then there is the Model which represents the data in the application.

### Coordinator pattern

Coordinator pattern is an idea of outsourcing navigation to an external class, that takes care of many aspects of navigation. It creates VMs and VCs and handles dependency injection. It’s a perfect solution for screen reusability as it breaks down connections between screens and makes every one of them an independent module. There are many articles on the internet and also many variations.
[](http://khanlou.com/2015/10/coordinators-redux/)

### ViewControllers/Views

Views display visual elements and controls on the screen. Every ViewController should have its own ViewModel

### ViewModel

ViewModel is a bit trickier. We are trying to keep it as stateless as possible (by using transformations instead of bindings) and expose only the public interface that is needed by Controller. To keep it organized we úed classes `Input` and `Output`. Every `ViewModel` should have those.

### Model

Models hold application data. They’re usually structs or simple classes(Codables).
