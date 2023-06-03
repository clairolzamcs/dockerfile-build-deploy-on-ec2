module "app_ecr_repo" {
  source    = "../modules/ecr"
  repo_name = "${var.env}-app"
}

module "db_ecr_repo" {
  source    = "../modules/ecr"
  repo_name = "${var.env}-db"
}
