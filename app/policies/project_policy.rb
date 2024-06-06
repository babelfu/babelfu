# frozen_string_literal: true

class ProjectPolicy
  attr_reader :user, :project

  def initialize(user, project)
    @user = user
    @project = project
  end

  def index?
    true
  end

  def user?
    user.present?
  end

  def sync?
    read_only_action_check
  end

  def show?
    read_only_action_check
  end

  def new?
    user.present?
  end

  def create?
    user.present?
  end

  def edit?
    edit_action_check
  end

  def update?
    edit_action_check
  end

  def destroy?
    edit_action_check
  end

  def commit_create?
    edit_action_check
  end

  def list_members?
    user.present? && project.users.include?(user)
  end

  private

  def edit_action_check
    user.present? && (project.users.include?(user) || check_project_collaborator)
  end

  def check_project_collaborator
    project.allow_remote_contributors? && project.collaborator?(user)
  end

  def read_only_action_check
    project.public? || project.users.include?(user)
  end
end
