class RoomPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  # Only admins can access 'new' and 'create'
  def create?
    user.admin?
  end

  def new?
    create? # Helpers can call other methods to stay DRY
  end

  # Only admins can access 'edit' and 'update'
  def update?
    user.admin?
  end

  def edit?
    update?
  end

  # Only admins can destroy
  def destroy?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
