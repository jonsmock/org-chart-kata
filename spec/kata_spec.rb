require 'kata'

describe OrgChart do
  let!(:org_chart) { OrgChart.new }
  let!(:root) { org_chart.root }

  it "has a root organization" do
    expect(root).to_not be_nil
  end

  it "can have many mid-tier organizations" do
    midtier1 = org_chart.create_organization(root)
    midtier2 = org_chart.create_organization(root)

    expect(org_chart.parent_of(midtier1)).to eq(root)
    expect(org_chart.parent_of(midtier2)).to eq(root)
  end

  it "can have many child organizations" do
    midtier = org_chart.create_organization(root)
    child1 = org_chart.create_organization(midtier)
    child2 = org_chart.create_organization(midtier)

    expect(org_chart.parent_of(child1)).to eq(midtier)
    expect(org_chart.parent_of(child2)).to eq(midtier)
  end

  it "does not allow organizations underneath child organizations" do
    midtier = org_chart.create_organization(root)
    child = org_chart.create_organization(midtier)
    expect {
      org_chart.create_organization(child)
    }.to raise_error(OrgChart::MaxDepthError)
  end
end

describe GateKeeper do
  let!(:org_chart) { OrgChart.new }
  let!(:root) { org_chart.root }
  let!(:midtier) { org_chart.create_organization(root) }
  let!(:child) { org_chart.create_organization(midtier) }

  let!(:gatekeeper) { GateKeeper.new(org_chart) }
  let!(:user) { User.new }

  it "does not allow access to root organization" do
    expect {
      gatekeeper.promote_admin(root, user)
    }.to raise_error(GateKeeper::InvalidRootRole)
    expect {
      gatekeeper.promote_user(root, user)
    }.to raise_error(GateKeeper::InvalidRootRole)
  end

  it "denies access for unseen users" do
    role = gatekeeper.role_for(midtier, user)
    expect(role).to eq(:denied)
  end

  it "promotes users to admin-level role" do
    gatekeeper.promote_admin(midtier, user)
    role = gatekeeper.role_for(midtier, user)
    expect(role).to eq(:admin)
  end

  it "promotes users to user-level role" do
    gatekeeper.promote_user(midtier, user)
    role = gatekeeper.role_for(midtier, user)
    expect(role).to eq(:user)
  end

  it "denies users access" do
    gatekeeper.promote_user(midtier, user)
    gatekeeper.deny(midtier, user)
    role = gatekeeper.role_for(midtier, user)
    expect(role).to eq(:denied)
  end

  it "does not get confused between two users" do
    other_user = User.new
    gatekeeper.promote_admin(midtier, user)
    gatekeeper.promote_user(midtier, other_user)

    role = gatekeeper.role_for(midtier, user)
    expect(role).to eq(:admin)

    role = gatekeeper.role_for(midtier, other_user)
    expect(role).to eq(:user)
  end

  it "uses inherited roles from organization if child organization has no specified role" do
    gatekeeper.promote_user(midtier, user)
    role = gatekeeper.role_for(child, user)
    expect(role).to eq(:user)
  end

  it "does not inherit role if child organization specifies a role" do
    gatekeeper.promote_admin(midtier, user)
    gatekeeper.promote_user(child, user)
    role = gatekeeper.role_for(child, user)
    expect(role).to eq(:user)
  end

  it "includes accessible organizations" do
    gatekeeper.promote_admin(midtier, user)
    organizations = gatekeeper.accessible(user)
    expect(organizations).not_to include(root)
    expect(organizations).to include(midtier)
    expect(organizations).to include(child)
  end

  it "removes denied organizations from the accessible list" do
    gatekeeper.promote_admin(midtier, user)
    gatekeeper.deny(child, user)
    organizations = gatekeeper.accessible(user)
    expect(organizations).not_to include(root)
    expect(organizations).to include(midtier)
    expect(organizations).not_to include(child)
  end
end
