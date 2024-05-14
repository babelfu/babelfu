# frozen_string_literal: true

Rails.application.config.active_record.encryption do |c|
  c.primary_key = Babelfu.config.active_record_encryption_primary_key
  c.deterministic_key = Babelfu.config.active_record_encryption_deterministic_key
  c.key_derivation_salt = Babelfu.config.active_record_encryption_key_derivation_salt
end
