//
//  APIConstant.swift
//  TenderWatch
//
//  Created by lanetteam on 27/06/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import Foundation

var BASE_URL = "http://192.168.200.34:4040/api/"

var LOGIN = "auth/login"
var CHANGE_PASSWORD = "users/changePassword/"+(USER?._id)!
