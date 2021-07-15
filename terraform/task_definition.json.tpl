{
  "containerDefinitions": [
    {
      "name": "app",
      "image": "${REPOSITORY_URL}:latest",
      "memory": 512,
      "cpu": 2,
      "essential": true,
      "environment": ["Beta - Production"]
    }
  ]
}
