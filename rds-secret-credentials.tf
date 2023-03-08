# ___________________________________________________________________________________
#| Date  : March, 08 2023        
#| Autor : Hermann90   
#| 
#| Description :
#|     The purpose of this file is to avoid that the password to be used by our 
#|     database is in clear in the terraform code                               
#|___________________________________________________________________________________

# First we can create a random generated password to use in secrets.
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "123567"
}
 
# Create an AWS secret for database account : hermannAccountDB
resource "aws_secretsmanager_secret" "secrethermannDB" {
   name = "hermannAccountDB"
}
 
# Create an AWS secret versions for database account (hermannAccountDB)
resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id = aws_secretsmanager_secret.secrethermannDB.id
  secret_string = <<EOF
   {
    "username": "hermannaccount",
    "password": "${random_password.password.result}"
   }
EOF
}
 
# Importing the AWS secrets created previously using arn.
data "aws_secretsmanager_secret" "secrethermannDB" {
  arn = aws_secretsmanager_secret.secrethermannDB.arn
}
 
# Importing the AWS secret version created previously using arn.
data "aws_secretsmanager_secret_version" "creds" {
  secret_id = data.aws_secretsmanager_secret.secrethermannDB.arn
}
 
# After importing the secrets storing into Locals
locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
}