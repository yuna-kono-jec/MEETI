//
//  SupabaseService.swift
//  MEETI
//
//  Created by cmStudent on 2026/10/16.
//

import Foundation
import Supabase

enum SupabaseService {
    static let client = SupabaseClient(
        supabaseURL: URL(
            string: "https://idyapfatxwaysidnjnzm.supabase.co"
        )!,
        supabaseKey: "sb_publishable_1ZZJHmDoMWFz4vx78NgAzg_hKvqZNyY"
    )
}
