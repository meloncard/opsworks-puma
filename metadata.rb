name        "opsworks-puma"
description "Manage the ruby app server puma on AWS OpsWorks"
maintainer  "Sport Ngin"
license     "MIT"
version     "0.0.1"

depends "nginx"
depends "deploy"

recipe "opsworks-puma", "Setup puma to run for all of a stacks rails applications"
