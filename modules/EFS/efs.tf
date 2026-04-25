resource "aws_kms_key" "bassiy_kms" {
  description             = "KMS key"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

# create key alias
resource "aws_kms_alias" "alias" {
  name          = "alias/kms"
  target_key_id = aws_kms_key.bassiy_kms.key_id
}

# create Elastic file system
resource "aws_efs_file_system" "bassiy_efs" {
  encrypted  = true
  kms_key_id = aws_kms_key.bassiy_kms.arn

  tags = merge(
    var.tags,
    {
      Name = "bassiy-efs"
    },
  )
}

# set first mount target for the EFS
resource "aws_efs_mount_target" "subnet_1" {
  file_system_id  = aws_efs_file_system.bassiy_efs.id
  subnet_id       = aws_subnet.private[0].id
  security_groups = [aws_security_group.datalayer_sg.id]
}

# set second mount target for the EFS
resource "aws_efs_mount_target" "subnet_2" {
  file_system_id  = aws_efs_file_system.bassiy_efs.id
  subnet_id       = aws_subnet.private[1].id
  security_groups = [aws_security_group.datalayer_sg.id]
}

# create access point for wordpress
resource "aws_efs_access_point" "wordpress" {
  file_system_id = aws_efs_file_system.bassiy_efs.id

  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    path = "/wordpress"

    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "0755"
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "wordpress-access-point"
    },
  )
}

# create access point for tooling
resource "aws_efs_access_point" "tooling" {
  file_system_id = aws_efs_file_system.bassiy_efs.id

  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    path = "/tooling"

    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "0755"
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "tooling-access-point"
    },
  )
}