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

  def edit?
    edit_action_check
  end

  def destroy?
    edit_action_check
  end

  def commit_create?
    edit_action_check
  end

  private

  def edit_action_check
    user.present? && project.users.include?(user)
  end

  def read_only_action_check
    project.public? || project.users.include?(user)
  end
end
