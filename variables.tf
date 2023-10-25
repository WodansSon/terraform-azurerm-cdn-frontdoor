# Global variables
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the CDN Front Door. Changing this forces a new resource to be created."
}
# DNS Zone variables
variable "dns_zone_name" {
  type        = string
  description = "The name of the DNS Zone. Must be a valid domain name. Changing this forces a new resource to be created."
}
# CDN Front Door Profile variables
variable "profile_name" {
  type        = string
  description = "The name of the CDN Front Door Profile. Changing this forces a new resource to be created."
}
variable "response_timeout_seconds" {
  type        = number
  default     = 120
  description = "The maximum response timeout in seconds. Possible values are between 16 and 240 seconds."
}
variable "profile_tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resource."
}
# CDN Origin Group variables
variable "origin_group_name" {
  type        = string
  description = "The name of the CDN Front Door Origin Group. Changing this forces a new resource to be created."
}
variable "health_probe" {
  type        = list(map(string))
  default     = []
  description = "List of objects that represent the configuration of the health probe."
  # health_probe = [{ interval_in_seconds = 0, path = "", protocol = "", request_type = "" }]
}
variable "load_balancing" {
  type        = list(map(string))
  default     = []
  description = "List of objects that represent the configuration of the load balancing."
  # load_balancing = [{ additional_latency_in_milliseconds = 0, sample_size = 0, successful_samples_required = 0 }]
}
variable "restore_traffic_time_to_healed_or_new_endpoint_in_minutes" {
  type        = number
  default     = 10
  description = "The amount of time which should elapse before shifting traffic to another endpoint when a healthy endpoint becomes unhealthy or a new endpoint is added. Possible values are between 0 and 50 minutes. Defaults to 10."
}
