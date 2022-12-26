variable "name" {
    description = "The name of the Log Analytics Solution."
}
variable "location" {
    description = "The location/region where the Log Analytics Solution is created."
}
variable "resource_group_name" {
    description = "The name of the resource group in which to create the Log Analytics Solution."
}
variable "log_analytics_workspace_name" {
    description = "The name of the Log Analytics Workspace."
}
variable "publisher" {
    description = "Optional. The product of the deployed solution. For Microsoft published gallery solution it should be `OMSGallery` and the target solution resource product will be composed as `OMSGallery/{name}`. For third party solution, it can be anything. This is case sensitive."
    default = "Microsoft"
}
variable "product" {
    description = "Optional. The publisher name of the deployed solution. For Microsoft published gallery solution, it is `Microsoft`."
    default = "OMSGallery"
}
variable "source_uri" {
    description = "Optional. The URI of the solution package in a storage account."
}
variable "source_resource_id" {
    description = "Optional. The resource id of the solution package in a storage account."
}
