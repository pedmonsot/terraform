resource "null_resource" "vagrant_up" {
  provisioner "local-exec" {
    command = "cd ${path.module} && vagrant up"
  }
}
