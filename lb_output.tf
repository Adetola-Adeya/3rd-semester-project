#load balancer outputs

output "target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group"
  value       = aws_lb_target_group.detola-target-gp.arn
}

output "lb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
  value       = aws_lb.detola-lb.zone_id
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.detola-lb.dns_name
}

