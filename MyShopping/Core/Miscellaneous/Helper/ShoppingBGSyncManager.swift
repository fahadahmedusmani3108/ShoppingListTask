//
//  ShoppingBGSyncManager.swift
//  MyShopping
//
//  Created by Fahad Ahmed Usmani on 16/05/2025.
//

import Foundation
import BackgroundTasks

public final class BackgroundSyncManager {
    public static let shared = BackgroundSyncManager()

    private var syncHandler: (() async -> Void)?

    private init() {}

    public func registerSyncHandler(_ handler: @escaping () async -> Void) {
        self.syncHandler = handler
    }

    /// Called by AppDelegate when background task triggers
    public func performSyncTask(task: BGTask) {
        guard let syncHandler = syncHandler else {
            task.setTaskCompleted(success: false)
            return
        }
        Task {
            await syncHandler()
            task.setTaskCompleted(success: true)
        }
        scheduleNextSync(with: task.identifier) // Schedule again
    }

    /// Should be called after sync to keep repeating
    public func scheduleNextSync(with id: String) {
        let request = BGAppRefreshTaskRequest(identifier: id)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule background sync: \(error)")
        }
    }
}
