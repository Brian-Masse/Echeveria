//
//  PermissionsManager.swift
//  Echeveria
//
//  Created by Brian Masse on 6/21/23.
//

import Foundation
import RealmSwift

enum QuerySubKey: String, CaseIterable {
    case testObject = "testObject"
    case account = "Account"
    case groups = "Groups"
    case groupSearch = "groupSearch"
    case games = "Games"
}

// if an object has a static function that takes an ID and returns an instance of that object from the local realm, it must subscribe to this protocol
// if the object is not found in the realm, then this runs it by a set of privacy measures (ie. should this object be able to access this other object)
// this could be denied if the requested user is private.
//TODO: Right now these permissions / verifications are being handled by the individual classes, but could be moved to RealmManager, if that isn't centralied enough

protocol UniquePermissionsView {
//    This sends all of the query permissions to their respective objects
//    ie. ProfileQueryPermissons.addQueries
//    These should all be pricate
    var baseKey: QuerySubKey { get }
    
    func updatePermissions() async -> Void
    
    func removePermissions() async -> Void
}

class QueryPermission<T: Object> {
    
    struct WrappedQuery<O: Object> {
        let name: String
        let query: ((Query<O>) -> Query<Bool>)
    }
    
    let baseQuery: (Query<T>) -> Query<Bool>
    var additionalQueries: [ WrappedQuery<T> ] = []
    
    init( baseQuery: @escaping (Query<T>) -> Query<Bool> ) {
        self.baseQuery = baseQuery
    }

    func addQueries( baseName: String, queries: [ ((Query<T>) -> Query<Bool>) ] ) async {
        for index in queries.indices {
            await self.addQuery(name: "\(baseName)\(index)", query: queries[index])
        }
    }
    
    func addQuery(name: String, query: @escaping ((Query<T>) -> Query<Bool>) ) async {
        if EcheveriaModel.shared.realmManager.checkSubscription(name: name) { return }
        
//        if !EcheveriaModel.shared.realmManager.checkSubscription(name: name) { return }
        let _ = await EcheveriaModel.shared.realmManager.addGenericSubcriptions(name: name, query: query)
        let wrappedQuery = WrappedQuery(name: name, query: query)
        additionalQueries.append(wrappedQuery)
    }
    
    func removeQueries(baseName: String) async {
        for wrappedQuery in additionalQueries {
            if wrappedQuery.name.contains( baseName ) {
                await removeQuery(wrappedQuery.name)
            }
        }
    }

    func removeQuery(_ name: String) async {
        await EcheveriaModel.shared.realmManager.removeSubscription(name: name)
        if let index = additionalQueries.firstIndex(where: { wrappedQuery in
            wrappedQuery.name == name
        }) {
            additionalQueries.remove(at: index)
        }
    }
    
    func removeAllQueries() async {
        for wrappedQuery in additionalQueries {
            await EcheveriaModel.shared.realmManager.removeSubscription(name: wrappedQuery.name)
        }
    }
}
