//
//  APIConstant.swift
//  TenderWatch
//
//  Created by lanetteam on 27/06/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import Foundation

var BASE_URL: String = "http://52.66.136.45:4000/api/"
//var BASE_URL: Strsng = "http://lanetteam.com:4000/api/"
//var BASE_URL: String = "http://192.168.200.18:4000/api/"

var CHECKEMAIL: String = (BASE_URL)+"auth/checkEmail"
var LOGIN: String = "auth/login"
var G_LOGIN: String = "auth/glogin"
var F_LOGIN: String = "auth/facelogin"
var SIGNUP: String = (BASE_URL)+"auth/register"
var FORGOT: String = (BASE_URL)+"auth/forgot"

var GET_TENDER: String = (BASE_URL)+"tender/getTenders"//tender: post .favorite: get
var DELETE_TENDER: String = (BASE_URL)+"tender/"
var UPLOAD_TENDER: String = (BASE_URL)+"tender/"
var ADD_REMOVE_FAVORITE: String = (BASE_URL)+"tender/favorite/" //add: put, remove: delete

var GOOGLE: String = (BASE_URL)+""
var GET_SERVICES: String = (BASE_URL)+"service/userServices"
var CATEGORY: String = "auth/category"
var COUNTRY: String = "auth/country"

var TENDER_DETAIL: String = (BASE_URL)+"tender/" //update: put (append id), detail: get
var INTERESTED: String = (BASE_URL)+"tender/interested/"

var READ_NOTIFY: String = (BASE_URL)+"notification" //list:get badge:put

var NOTIFICATION_DETAIL: String = (BASE_URL)+"notification/" //read: put (with id)
var NOTIFICATION: String = (BASE_URL)+"notification/delete"

var SUPPORT: String = (BASE_URL)+"support"
var RATING: String = (BASE_URL)+"review/" //submit .post  user all get review if client need any review in text format  get 

var USERS: String = (BASE_URL)+"users/"
var PAYPAL: String = (BASE_URL)+"paypal"

var PAYMENTS: String = (BASE_URL)+"payments/"
