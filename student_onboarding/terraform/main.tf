terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}


# ---------------------------------------------------------
# Google Cloud Provider
# ---------------------------------------------------------

provider "google" {
  project = var.project_id
  region  = var.region
}


# ---------------------------------------------------------
# D0 Raw Landing - Google Cloud Storage
# ---------------------------------------------------------

resource "google_storage_bucket" "d0_raw_landing" {
  name     = "habotconnect-d0-raw-landing-2026"
  location = var.region

  # Prevent object-level ACLs and manage access using IAM.
  uniform_bucket_level_access = true

  # Prevent accidental public exposure.
  public_access_prevention = "enforced"

  # Keep previous versions of objects.
  versioning {
    enabled = true
  }

  # Cost-control assumption:
  # Delete objects older than 30 days.
  lifecycle_rule {
    condition {
      age = 30
    }

    action {
      type = "Delete"
    }
  }
}


# ---------------------------------------------------------
# D1 Staged/Enforced - BigQuery Dataset
# ---------------------------------------------------------

resource "google_bigquery_dataset" "d1_staged" {
  dataset_id = "d1_staged_enforced"
  project    = var.project_id
  location   = var.region

  description = "Validated and enforced student onboarding data."

  # Prevent Terraform from automatically deleting
  # dataset contents during destruction.
  delete_contents_on_destroy = false
}


# ---------------------------------------------------------
# IAM Security - D0 Raw Landing Bucket
# ---------------------------------------------------------

resource "google_storage_bucket_iam_member" "d0_raw_viewer" {
  bucket = google_storage_bucket.d0_raw_landing.name

  # Least-privilege read-only access.
  role = "roles/storage.objectViewer"

  member = "user:${var.iam_user_email}"
}


# ---------------------------------------------------------
# IAM Security - D1 BigQuery Dataset
# ---------------------------------------------------------

resource "google_bigquery_dataset_iam_member" "d1_data_viewer" {
  project    = google_bigquery_dataset.d1_staged.project
  dataset_id = google_bigquery_dataset.d1_staged.dataset_id

  # Least-privilege read access to BigQuery data.
  role = "roles/bigquery.dataViewer"

  member = "user:${var.iam_user_email}"
}


# ---------------------------------------------------------
# BigQuery Table - Student Onboarding
# ---------------------------------------------------------

resource "google_bigquery_table" "student_onboarding" {
  dataset_id = google_bigquery_dataset.d1_staged.dataset_id
  table_id   = "student_onboarding"

  deletion_protection = true

  schema = jsonencode([
    {
      name = "student_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "age"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "parent_email"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "requires_learning_support"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "region"
      type = "STRING"
      mode = "REQUIRED"
    }
  ])
}


# ---------------------------------------------------------
# Row-Level Security - North Region
# ---------------------------------------------------------

resource "google_bigquery_row_access_policy" "north_region_policy" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.d1_staged.dataset_id
  table_id   = google_bigquery_table.student_onboarding.table_id

  policy_id = "north_region_access"

  # Only rows belonging to the North region are visible
  # through this policy.
  filter_predicate = "region = 'North'"

  grantees = [
    "user:${var.iam_user_email}"
  ]
}
