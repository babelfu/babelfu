# frozen_string_literal: true

module ApiWrapper
  extend ActiveSupport::Concern

  RequestError = Class.new(StandardError)

  delegate :client, :build_client, to: :authentication

  def authentication
    raise NotImplementedError
  end

  class_methods do
    def api_wrapper(original_method_name)
      raise ArgumentError, "Method name must start with _" unless original_method_name.start_with?("_")

      method_name = original_method_name[1..].to_sym

      define_method(method_name) do |*args, **kwargs, &block|
        retried = false
        begin
          res = send(original_method_name, *args, **kwargs, &block)
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
end
