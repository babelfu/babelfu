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
    explore?
  end

  def propose?
    project_member? || check_project_collaborator
  end

  def explore?
    project.public? || project_member? || check_project_collaborator
  end

  def create?
    user.present?
  end

  def update?
    project_member?
  end

  def destroy?
    project_member?
  end

  def commit?
    project_member? || check_project_collaborator
  end

  def list_members?
    project_member?
  end

  private

  def project_member?
    user && project.users.include?(user)
  end

  def check_project_collaborator
    user && project.allow_remote_contributors? && project.collaborator?(user)
  end
end
