import Cocoa

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
        
        async let result1 = await executor.getNewUUID()
        async let result2 = await executor.getNewUUID()
        async let result3 = await executor.getNewUUID()
        async let result4 = await executor.getNewUUID()
        
        let result = await [try result1, try result2, try result3, try result4]
    }
    
    print("-- This is the parallel execution but with a request that fails")
    // In this case the big difference is on the automatic cancel of the other requests
    // This is replicating the TakGroup
    
    
}


    

