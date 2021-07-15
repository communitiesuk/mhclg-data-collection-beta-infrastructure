#!/bin/bash

# Adding cluster name in ecs config
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
