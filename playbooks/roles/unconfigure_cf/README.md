CloudForms Unconfigure Playbook
=========

This playbook unconfigures a Cloudforms / ManageIQ appliace to leave it as just deployed (with DB configured).
It takes care of properly unconfiguring the Ansible role in CloudForms

Requirements
------------

Tested with Cloudforms 4.7

Role Variables
--------------

No variables required to run this playbook.
CloudForms / ManageIQ requires the var "DISABLE_DATABASE_ENVIRONMENT_CHECK" to be set to 1. 

Dependencies
------------

No dependencies required

Example Playbook
----------------

  ---
  - hosts: cf.example.com
    roles:
      - unconfigure_cf

    vars:
      rails_env:
        DISABLE_DATABASE_ENVIRONMENT_CHECK: 1

License
-------

BSD

Author Information
------------------

Miguel Pérez Colino @mperezco at GitHub, @mmmmmmpc at Twitter.
