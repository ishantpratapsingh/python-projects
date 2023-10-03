# main.tf

provider "docker" {
  host = "tcp://localhost:2375"  # Docker daemon host (can be customized)
}

resource "docker_image" "hello_world_app" {
  name         = "your-dockerhub-username/hello-world-app"  # Replace with your Docker Hub username
  build_context = "./"  # Directory containing Dockerfile and app.py
  dockerfile    = "Dockerfile"
}

output "image_id" {
  value = docker_image.hello_world_app.id
}
