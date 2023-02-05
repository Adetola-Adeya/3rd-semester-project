variable "domain_name" {
  default    = "detolamain.studio"
  type        = string
  description = "domain name"
}
# get hosted zone details

resource "aws_route53_zone" "hosted_zone" {
  name = var.domain_name

  tags = {
    Environment = "dev"
  }
}
# create a record set in route 53
resource "aws_route53_record" "site_domain" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "terraform-test.${var.domain_name}"
  type    = "A"
  alias {
    name                   = aws_lb.detola-lb.dns_name
    zone_id                = aws_lb.detola-lb.zone_id
    evaluate_target_health = true
  }
}
