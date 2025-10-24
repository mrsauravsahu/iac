resource "random_password" "db_admin" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*()-_=+[]{};:,.?/|"
  upper            = true
  lower            = true
}