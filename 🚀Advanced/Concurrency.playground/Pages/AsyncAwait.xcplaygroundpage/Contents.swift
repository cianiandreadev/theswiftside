import Foundation

struct APIExecutor {
    
    private let baseURL = URL(string:"https://httpbin.org")!
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    
    func get() async throws -> ResponseDTO {
        let url = baseURL.appendingPathComponent("get")
        let request = URLRequest(url: url)
        let result = try await session.data(for: request)
        
        let dto = try decoder.decode(ResponseDTO.self, from: result.0)
        
        return dto
    }
    
    func getNewUUID() async throws -> String {
        print("🔼 Started Request")
        try await Task.sleep(for: .seconds(Int.random(in: 2...4)))
        print("🔽 Completed Request")
        return UUID().uuidString
    }
    
    func getNewUUIDButFails() async throws -> String {
        print("🔼 Started Request")
        try await Task.sleep(for: .seconds(1))
        throw SomeError.GeneralError
    }
    
    struct ResponseDTO: Decodable {
        let url: String
    }
    
    enum SomeError: Error {
        case GeneralError
    }
    
}

/**
 # Sequence of async operation
 
 Those go one after the other
 */

let executor = APIExecutor()

Task {
    
    print("-- This is the sequencial execution")
    
    do {
        let result1 = try await executor.getNewUUID()
        let result2 = try await executor.getNewUUID()
        let result3 = try await executor.getNewUUID()
        let result4 = try await executor.getNewUUID()
    }
    
    print("-- This is the parallel execution")
    
    do {
        
        async let result1 = executor.getNewUUID()
        async let result2 = executor.getNewUUID()
        async let result3 = executor.getNewUUID()
        async let result4 = executor.getNewUUID()
        
        let result = await [try result1, try result2, try result3, try result4]
        // Note: People often confuse async let with lazy. But async let is eager — as soon as it’s declared, it kicks off a new task.
        //  the array awaits the results of those background tasks, but doesn’t start them.
    }
    
    print("-- This is the parallel execution but with a request that fails")
    // In this case the big difference is on the automatic cancel of the other requests
    // This is replicating the TakGroup
    
    do {
        
        async let result1 = executor.getNewUUID()
        async let result2 = executor.getNewUUID()
        async let result3 = executor.getNewUUIDButFails()
        async let result4 = executor.getNewUUID()
        
        let result = try await [result1, result2, result3, result4]
    } catch {
        print("Code execution exited here because getNewUUIDButFails fails")
    }
    
    /**
     
     ## Performance Benefits of async let
     
     Unlike Task { }, which creates unstructured concurrent work, async let ensures that tasks execute efficiently within Swift’s cooperative thread pool. This means:

     Avoiding excessive thread creation.
     Ensuring optimal CPU utilization.
     Reducing memory overhead compared to manually created tasks.
     Lastly, requests run in parallel, so they’ll execute faster since one does not have to wait for another to finish.
     
     ## Note regarding async let:
     
     Avoid async let if:

     You don’t need parallel execution—use await normally
     You need dynamic task spawning—use TaskGroup instead
     You need manual task cancellation—use a TaskGroup instead if you want to run tasks in parallel while having the option to control cancellation manually
     
    */
    
}


    

