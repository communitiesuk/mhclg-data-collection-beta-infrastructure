#TODO add an image lifecycle policy so that we don't keep all image versions forever
# something like the last 5 or so should be enough

resource "aws_ecr_repository" "container_repository" {
  name = "container-repository"

  tags = var.default_tags
}
