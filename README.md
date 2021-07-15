# MHCLG Data Collection Beta

This beta aims to provide a web application for collecting Case Level Letting and Sales records for Social Housing in England via form, bulk upload and API submission. It is intended for use by housing officers from local authorities and housing providers and associations.

## Infrastructure

Infrastructure is provisioned via Terraform. AWS S3 is used as the state store and Dynamo DB for locking. Set up for these is not included in the Terraform files in this repository, but details can be found in `./terraform/provider.tf`. Pull requests run Terraform format check and Terraform plan. Commits to main run Terraform Apply as well.

All code can be found in `/terraform`


## Web App

The main codebase is a Ruby on Rails app that can be found in [data-collector](data-collector)
