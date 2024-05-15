# frozen_string_literal: true

require Rails.root.join('lib/babelfu')

Rails.application.configure do |c|
  c.config.active_record.encryption.primary_key = Babelfu.config.active_record_encryption_primary_key
  c.config.active_record.encryption.deterministic_key = Babelfu.config.active_record_encryption_deterministic_key
  c.config.active_record.encryption.key_derivation_salt = Babelfu.config.active_record_encryption_key_derivation_salt
end
