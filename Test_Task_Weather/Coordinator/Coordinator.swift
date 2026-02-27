//
//  Coordinator.swift
//  Test_Task_Weather
//
//  Created by developer on 27.02.26.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}
