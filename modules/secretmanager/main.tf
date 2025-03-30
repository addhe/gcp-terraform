resource "google_secret_manager_secret" "secret" {
  for_each = var.secrets

  secret_id = each.value.secret_id

  labels = merge(each.value.labels, {
    environment = var.environment
    managed_by  = "terraform"
  })

  replication {
    dynamic "user_managed" {
      for_each = each.value.replication.automatic ? [] : [each.value.replication.user_managed]
      content {
        dynamic "replicas" {
          for_each = user_managed.value.replicas
          content {
            location = replicas.value.location
            dynamic "customer_managed_encryption" {
              for_each = replicas.value.customer_managed_encryption != null ? [replicas.value.customer_managed_encryption] : []
              content {
                kms_key_name = customer_managed_encryption.value.kms_key_name
              }
            }
          }
        }
      }
    }

    automatic = each.value.replication.automatic
  }
}

resource "google_secret_manager_secret_version" "secret_version" {
  for_each = var.secrets

  secret      = google_secret_manager_secret.secret[each.key].id
  secret_data = each.value.secret_data
}

# Grant access to service accounts
resource "google_secret_manager_secret_iam_member" "secret_access" {
  for_each = {
    for access in flatten([
      for sa in var.service_accounts : [
        for secret in sa.secrets : {
          sa_email = sa.email
          role     = sa.role
          secret   = secret
        }
      ]
    ]) : "${access.sa_email}-${access.secret}" => access
  }

  project   = google_secret_manager_secret.secret[keys(google_secret_manager_secret.secret)[0]].project
  secret_id = each.value.secret
  role      = each.value.role
  member    = "serviceAccount:${each.value.sa_email}"
}
