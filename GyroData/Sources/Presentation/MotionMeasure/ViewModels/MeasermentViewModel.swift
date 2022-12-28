//
//  MeasermentViewModel.swift
//  GyroData
//
//  Created by 우롱차 on 2022/12/27.
//

import Foundation

protocol MeasermentViewModelInput {

    func measerStart(type: MotionType)
    func measerStop(type: MotionType)
    func measerSave(type: MotionType) throws
    func measerCancle(type: MotionType)
    
}

protocol MeasermentViewModelOutput {
    
    var status: Observable<MeasermentStatus> { get }
    var motions: Observable<[MotionValue]> { get }
    var currentMotion: Observable<MotionValue?> { get }
    
}

enum MeasermentStatus {
    case ready, start, stop
}

protocol MeasermentViewModel: MeasermentViewModelInput, MeasermentViewModelOutput {}

final class DefaultMeasermentViewModel: MeasermentViewModel {
    
    private let storage: MotionStorage
    private let coreMotionManager: CoreMotionManager
    var motions: Observable<[MotionValue]> = .init([])
    var status: Observable<MeasermentStatus> = .init(.ready)
    var currentMotion: Observable<MotionValue?> = .init(nil)
    
    init(
        manger: CoreMotionManager = CoreMotionManager(),
        storage: CoreDataMotionStorage = .init()
    ) {
        self.coreMotionManager = manger
        self.storage = storage
    }
    
    func measerStart(type: MotionType) {
        switch type {
        case .gyro:
            coreMotionManager.bind(gyroHandler: { data, error in
                if let data = data {
                    let motionValue = MotionValue(data)
                    self.currentMotion.value = motionValue
                    self.motions.value.append(motionValue)
                }
            })
            coreMotionManager.startUpdates(type: .gyro)
        case .accelerometer:
            coreMotionManager.bind(accHandler: { data, error in
                if let data = data {
                    let motionValue = MotionValue(data)
                    self.currentMotion.value = motionValue
                    self.motions.value.append(motionValue)
                }
            })
            coreMotionManager.startUpdates(type: .accelerometer)
        }
    }
    
    func measerStop(type: MotionType) {
        switch type {
        case .gyro:
            coreMotionManager.stopUpdates(type: .gyro)
        case .accelerometer:
            coreMotionManager.stopUpdates(type: .accelerometer)
        }
    }
    
    func measerSave(type: MotionType) throws {
        let timeInterval = TimeInterval( Double(motions.value.count) * 0.1)
        let saveData = Motion(uuid: UUID(), type: type, values: motions.value, date: Date(), duration: timeInterval)
        storage.insert(saveData)
        try MotionFileManager.shared.save(data: saveData.toFile())
    }
    
    func measerCancle(type: MotionType) {
        motions.value = []
        status.value = .ready
        currentMotion.value = nil
    }
}
