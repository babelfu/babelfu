# frozen_string_literal: true

class Babelfu::Config
  def mailer_from
    ENV["MAILER_FROM"] || "no-reply@example.com"
  end

  def github_domain
    ENV.fetch("GITHUB_DOMAIN", "https://github.com")
  end

  def github_app_private_key
    ENV["GITHUB_APP_PRIVATE_KEY"] || credentials_github_app&.private_key
  end

  def github_app_client_id
    ENV["GITHUB_APP_CLIENT_ID"] || credentials_github_app&.client_id
  end

  def github_app_client_secret
    ENV["GITHUB_APP_CLIENT_SECRET"] || credentials_github_app&.client_secret
  end

  def github_app_id
    ENV["GITHUB_APP_ID"] || credentials_github_app&.id
  end

  def credentials_github_app
    Rails.application.credentials.github_app
  end

  def active_record_encryption_primary_key
    ENV["ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY"] || credentials_active_record_encryption&.primary_key
  end

  def active_record_encryption_deterministic_key
    ENV["ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY"] || credentials_active_record_encryption&.deterministic_key
  end

  def active_record_encryption_key_derivation_salt
    ENV["ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT"] || credentials_active_record_encryption&.key_derivation_salt
  end

  def credentials_active_record_encryption
    Rails.application.credentials.active_record_encryption
  end
end
