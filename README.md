# SQL-IIS
########################
##  sql.ps1 performs  ##
########################
- Install SQL 2016
- - SSIS
- - Choose collation Latin_CI_AI
- - SQL management Studio 2016

##USAGE:
sql.ps1 -WinSources <path-to-src> to change source directory
sql.ps1 -domAccount <domain\user> to add AD admin to MSSQL instance. By default admin will be deploying user.

########################
##  iis.ps1 performs  ##
########################
- Install IIS
-- Install Web Depoly
-- Install URL Rewrite
-- Create zip and deploy with msdeploy

USAGE:
Site name to deploy in is "my-test-app.test"

