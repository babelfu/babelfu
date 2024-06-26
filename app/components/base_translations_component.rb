# frozen_string_literal: true

class BaseTranslationsComponent < ViewComponent::Base
  include Pundit::Authorization

  def filter_path
    raise NotImplementedError
  end

  def clear_path
    raise NotImplementedError
  end

  def project
    raise NotImplementedError
  end

  def translations_presenter
    raise NotImplementedError
  end

  def query_params_without_filter
    request.query_parameters.except(:filter_key)
  end
end
