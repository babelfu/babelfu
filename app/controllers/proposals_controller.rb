# frozen_string_literal: true

class ProposalsController < ApplicationController
  before_action :find_project
  def create
    proposal = @project.proposals.where(branch_name: params[:branch_name], locale: params[:locale], key: params[:key]).first_or_initialize
    proposal.value = params[:value]
    proposal.save!
    render json: proposal
  end

  private

  def find_project
    @project = current_user.projects.find_by!(slug: params[:project_id])
  end
end
