protocol Coordinatable: AnyObject {
    func startFlow()
}

class BaseCoordinator {
    private var childCoordinators: [Coordinatable] = []
    
    func addDependency(_ coordinator: Coordinatable) {
        for childCoordinator in childCoordinators where childCoordinator === coordinator {
            return
        }
        childCoordinators.append(coordinator)
    }
    
    func removeDependency(_ coordinator: Coordinatable?) {
        guard let coordinator = coordinator else { return }
        childCoordinators.removeAll { childCoordinator in
            childCoordinator === coordinator
        }
    }
}
