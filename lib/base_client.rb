# frozen_string_literal: true

class BaseClient
  MAX_TIME_TO_WAIT_FOR_LOCK = 2

  RequestError = Class.new(StandardError)

  class << self
    def api_wrapper(method_names)
      Array.wrap(method_names).each do |method_name|
        original_method = instance_method(method_name)
        define_method(method_name) do |*args, **kwargs, &block|
          retried = false
          res = original_method.bind(self).call(*args, **kwargs, &block)
          raise RequestError, res.inspect unless client.last_response.status.in?([200, 201])

          res
        rescue Octokit::Unauthorized => e
          Rails.logger.error("Unauthorized error: #{e.inspect}")
          if retried
            raise e
          else
            retried = true
            build_client(force: true)
            retry
          end
        end
      end
    end
  end

  def client
    @client || build_client
  end

  def build_client(force: false)
    @client = Octokit::Client.new(access_token: fetch_access_token!(force:))
  end

  def fetch_access_token!(force: false)
    # We just return the access token if it's valid and we are not forcing
    # We would like to force it when the request fails with an Unauthorized error
    return access_token if !force && valid_access_token?

    # We use an advisory lock to avoid multiple requests to fetch the access token
    # at the same time. For example when syncing a branch, it trigger multiple
    # SyncBranchFileJob
    ActiveRecord::Base.with_advisory_lock!(fetch_access_token_mutex_key, MAX_TIME_TO_WAIT_FOR_LOCK) do
      # Becuase we could be waiting for the lock, maybe the token was already fetched
      # by another process, so we check again if the token is valid before fetching it
      # again and we return it if it's valid unless we are forcing it.
      return access_token if !force && valid_access_token?

      fetch_and_save_access_token!

      access_token
    end
  end
end
