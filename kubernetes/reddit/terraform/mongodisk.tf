resource "google_compute_disk" "mongo" {
  name = "reddit-mongo-disk"
  type = "pd-ssd"
  size = 25
  zone = var.zone
}
