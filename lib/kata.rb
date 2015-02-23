Organization = Class.new
User = Class.new

class GateKeeper
  attr_reader :org_chart

  InvalidRootRole = Class.new(StandardError)

  def initialize(org_chart)
    @org_chart = org_chart
    @roles = Hash.new { Hash.new }
  end

  def promote_admin(organization, user)
    raise InvalidRootRole if organization == org_chart.root
    set_role(organization, user, :admin)
  end

  def promote_user(organization, user)
    raise InvalidRootRole if organization == org_chart.root
    set_role(organization, user, :user)
  end

  def deny(organization, user)
    set_role(organization, user, :denied)
  end

  def role_for(organization, user)
    role = org_chart.with_ancestors(organization)
                    .map { |org| role_at(org, user) }
                    .compact
                    .first
    role || :denied
  end

  def accessible(user)
    org_chart.all.select { |org| role_for(org, user) != :denied }
  end

  private

  def set_role(organization, user, role)
    @roles[organization] = @roles[organization].merge(user => role)
  end

  def role_at(organization, user)
    @roles[organization][user]
  end
end

class OrgChart
  attr_reader :root

  MAX_DEPTH = 3
  MaxDepthError = Class.new(StandardError)

  def initialize
    @root = Organization.new
    @parents = {}
  end

  def create_organization(parent)
    raise MaxDepthError if with_ancestors(parent).size == MAX_DEPTH

    child = Organization.new
    @parents[child] = parent
    child
  end

  def all
    [@root] + @parents.keys
  end

  def parent_of(organization)
    @parents.fetch(organization)
  end

  def with_ancestors(organization)
    if organization == root
      [organization]
    else
      parent = parent_of(organization)
      [organization] + with_ancestors(parent)
    end
  end
end
