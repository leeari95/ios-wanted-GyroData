//
//  AppCoordinator.swift
//  GyroData
//
//  Created by Ari on 2022/12/27.
//

import UIKit

final public class AppCoordinator: Coordinator {
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    public init(navigationConrtoller: UINavigationController) {
        self.navigationController = navigationConrtoller
    }
    
    public func start() {
        let coordinator = makeAuthCoordinator()
        coordinator.start()
    }
}

private extension AppCoordinator {
    func makeAuthCoordinator() -> Coordinator {
        let coordinator = MotionListCoordinator(navigationConrtoller: navigationController)
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        
        return coordinator
    }
}