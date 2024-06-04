# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :initialize_component_context

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized(exception)
    Rails.logger.error(exception)
    flash[:error] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end

  def initialize_component_context
    Current.user = current_user
  end

  def filter_locales
    session_key = "filter_locales_#{@project.id}"
    filter_locales = params[:filter_locales].presence || session[session_key] || [@project.default_locale]
    session[session_key] = filter_locales if filter_locales.present?
    filter_locales
  end
end
