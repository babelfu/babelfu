# frozen_string_literal: true

module GithubAppClient
  BadRefreshToken = Class.new(StandardError)

  class << self
    def client
      Octokit::Client.new(bearer_token: jwt, client_id:, client_secret:)
    end

    def generate_access_token_from_refresh_token(refresh_token)
      # TODO: use Balelfu.config
      params = {
        "client_id" => client_id,
        "client_secret" => client_secret,
        "refresh_token" => refresh_token,
        "grant_type" => "refresh_token"
      }
      result = Net::HTTP.post(
        URI("https://github.com/login/oauth/access_token"),
        URI.encode_www_form(params),
        { "Accept" => "application/json" }
      )

      data = parse_response(result)
      raise BadRefreshToken, data if data["error"]

      data
    end

    def exchange_code(code)
      params = {
        "client_id" => client_id,
        "client_secret" => client_secret,
        "code" => code
      }
      result = Net::HTTP.post(
        URI("https://github.com/login/oauth/access_token"),
        URI.encode_www_form(params),
        { "Accept" => "application/json" }
      )

      parse_response(result)
    end

    def parse_response(response)
      case response
      when Net::HTTPOK
        JSON.parse(response.body)
      else
        puts response
        puts response.body
        {}
      end
    end

    def url
      "https://github.com/login/oauth/authorize?client_id=#{client_id}"
    end

    def app
      @app ||= client.app
    end

    def jwt
      payload = {
        # The time that this JWT was issued, _i.e._ now.
        iat: Time.now.to_i,

        # How long is the JWT good for (in seconds)?
        # Let's say it can be used for 10 minutes before it needs to be refreshed.
        # TODO we don't actually cache this token, we regenerate a new one every time!
        exp: Time.now.to_i + (10 * 60),

        # Your GitHub App's identifier number, so GitHub knows who issued the JWT, and know what permissions
        # this token has.
        iss: app_id
      }

      # Cryptographically sign the JWT
      JWT.encode(payload, private_key, "RS256")
    end

    # TODO: read the file path from config or ENV
    def private_key
      @private_key ||= OpenSSL::PKey::RSA.new(Babelfu.config.github_app_private_key)
    end

    def client_id
      Babelfu.config.github_app_client_id
    end

    def client_secret
      Babelfu.config.github_app_client_secret
    end

    def app_id
      Babelfu.config.github_app_id
    end

    def credentials
      @credentials ||= Babelfu.config
    end
  end
end
