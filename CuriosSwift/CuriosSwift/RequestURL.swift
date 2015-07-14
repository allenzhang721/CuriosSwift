//
//  RequestURL.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/13/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

let addEditedFile = ["publish", "addEditFile"] // save the edited book to server
let getPublishID = ["publish", "getPublishID"] // get a new ID when create a new book
let addPublishFile = ["publish", "publishFile"] // finish published use this API to record the pubish info and get

let uploadCompleteURL = ["upload", "uploadComplete"]
let getPublishToken = ["upload", "publishUptoken"] // upload non-resourse(image) file / data's token
let getImageToken = ["upload", "imageUptoken"] // upload resourse(image) file / data's token