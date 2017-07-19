//
//  APIConstant.swift
//  TenderWatch
//
//  Created by lanetteam on 27/06/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import Foundation

//var BASE_URL: String = "http://lanetteam.com:3000/api/"
var BASE_URL: String = "http://192.168.200.78:3000/api/"


var LOGIN: String = "auth/login"
var G_LOGIN: String = "auth/glogin"
var F_LOGIN: String = "auth/facelogin"
var SIGNUP: String = (BASE_URL)+"auth/register"
var FORGOT: String = (BASE_URL)+"auth/forgot"

var GET_TENDER: String = (BASE_URL)+"tender/getTenders"
var DELETE_TENDER: String = (BASE_URL)+"tender/"
var UPDATE: String = (BASE_URL)+"users/"+(USER?._id)!
var CHANGE_PASSWORD: String = (BASE_URL)+"users/changePassword/"+(USER?._id)!
var UPLOAD_TENDER: String = (BASE_URL)+"tender"
var FAVORITE: String = (BASE_URL)+"favourite/getFavourites"

var GOOGLE: String = (BASE_URL)+""
var GET_SERVICES: String = (BASE_URL)+"service/userServices"
var CATEGORY: String = "auth/category"
var COUNTRY: String = "auth/country"

var TENDER_DETAIL: String = (BASE_URL)+"tender"
