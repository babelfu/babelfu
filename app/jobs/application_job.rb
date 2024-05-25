# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  # This error can happen on ProjectClient when fetching the access token if
  # Github response takes too long
  retry_on WithAdvisoryLock::FailedToAcquireLock, attempts: 3

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
