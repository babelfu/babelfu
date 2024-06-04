# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!

  before_action :initialize_component_context
  def initialize_component_context
    Current.user = current_user
  end


  private

  def filter_locales
    session_key = "filter_locales_#{@project.id}"
    filter_locales = params[:filter_locales].presence || session[session_key] || [@project.default_locale]
    session[session_key] = filter_locales if filter_locales.present?
    filter_locales
  end
end
