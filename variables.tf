variable "force_destroy" {
  default     = false
  type        = bool
  description = "DATA LOSS WARNING. A boolean that indicates all objects should be deleted from the logs and playbooks buckets so that the buckets can be destroyed without error. FILES ARE NOT RECOVERABLE."
}
