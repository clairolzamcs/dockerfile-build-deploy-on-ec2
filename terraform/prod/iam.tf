# # Assume Policy document for IAM instance profile role
# data "aws_iam_policy_document" "instance_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }
#   }
# }

# # Inline Policy document for IAM instance profile role that allows pulling from ECR
# data "aws_iam_policy_document" "get_ecr_images" {
#   statement {
#     actions = [
#       "ecr:BatchGetImage",
#       "ecr:BatchCheckLayerAvailability",
#       "ecr:GetDownloadUrlForLayer"
#     ]
#     resources = ["*"]
#   }
# }

# # IAM role that uses both above policy documents
# resource "aws_iam_role" "app" {
#   name               = "app_instance_role"
#   path               = "/system/"
#   assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json

#   inline_policy {
#     name   = "app_instance_role_policy"
#     policy = data.aws_iam_policy_document.get_ecr_images.json
#   }
# }

# # Instance profile to be used by app EC2 sever
# resource "aws_iam_instance_profile" "app" {
#   name = "app_instance_profile"
#   role = aws_iam_role.app.name
# }

data "aws_iam_instance_profile" "lab_profile" {
  name = "LabInstanceProfile"
}