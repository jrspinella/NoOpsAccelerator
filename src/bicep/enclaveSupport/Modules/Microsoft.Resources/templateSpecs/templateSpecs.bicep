/* Copyright (c) Microsoft Corporation. Licensed under the MIT license. */
param name string
param version string
param location string = resourceGroup().location
param template object
param tags object = {}

resource templateSpec 'Microsoft.Resources/templateSpecs@2021-05-01' = {
   name: name
   location: location
   properties: {
     displayName: name        
   }
   resource templateSpecVersion 'versions' = {
    name: version
    location: location  
    properties: {
      mainTemplate: template       
    }
    tags: tags    
  } 
}
