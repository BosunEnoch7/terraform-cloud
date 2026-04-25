resource "aws_acm_certificate" "bassiy" {
  domain_name       = "*.bassiy.site"
  validation_method = "DNS"
}


# calling the hosted zone
data "aws_route53_zone" "bassiy" {
  name         = "bassiy.site"
  private_zone = false
}


# selecting validation method
resource "aws_route53_record" "bassiy" {
  for_each = {
    for dvo in aws_acm_certificate.bassiy.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }


  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.bassiy.zone_id
}


# validate the certificate through DNS method
resource "aws_acm_certificate_validation" "bassiy" {
  certificate_arn         = aws_acm_certificate.bassiy.arn
  validation_record_fqdns = [for record in aws_route53_record.bassiy : record.fqdn]
}


# create records for tooling
resource "aws_route53_record" "tooling" {
  zone_id = data.aws_route53_zone.bassiy.zone_id
  name    = "tooling.bassiy.site"
  type    = "A"


  alias {
    name                   = aws_lb.ext-alb.dns_name
    zone_id                = aws_lb.ext-alb.zone_id
    evaluate_target_health = true
  }
}


# create records for wordpress
resource "aws_route53_record" "wordpress" {
  zone_id = data.aws_route53_zone.bassiy.zone_id
  name    = "wordpress.bassiy.site"
  type    = "A"


  alias {
    name                   = aws_lb.ext-alb.dns_name
    zone_id                = aws_lb.ext-alb.zone_id
    evaluate_target_health = true
  }
}