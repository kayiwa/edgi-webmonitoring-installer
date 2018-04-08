output "elb.hostname" {
  value = "${aws_elb.web-monitoring-ui.dns_name}"
}

output "docnow.ip" {
  value = "${aws_instance.web-monitoring-ui.*.private_ip}"
}
