###### vpc/outputs.tf 
output "aws_public_subnet" {
  value = aws_subnet.public_cloudquick_subnet.*.id
}
output "aws_private_subnet" {
  value = aws_subnet.private_cloudquick_subnet.*.id
}
output "vpc_id" {
  value = aws_vpc.cloudquick.id
}
