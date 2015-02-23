require 'kata'

Given(/^a user with an organizational chart with root "(.*?)"$/) do |root_name|
  @user = User.new
  @org_names = {}

  @org_chart = OrgChart.new
  @gatekeeper = GateKeeper.new(@org_chart)

  @org_names[root_name] = @org_chart.root
end

Given(/^the organization "(.*?)" is nested under "(.*?)"$/) do |child_name, parent_name|
  parent = @org_names.fetch(parent_name)
  child = @org_chart.create_organization(parent)
  @org_names[child_name] = child
end

When(/^the user is granted admin access to "(.*?)"$/) do |org_name|
  organization = @org_names.fetch(org_name)
  @gatekeeper.promote_admin(organization, @user)
end

When(/^the user is denied access to "(.*?)"$/) do |org_name|
  organization = @org_names.fetch(org_name)
  @gatekeeper.deny(organization, @user)
end

Then(/^the user should( not)? have (admin|user) access to "(.*?)"$/) do |no_access, role_str, org_name|
  organization = @org_names.fetch(org_name)
  role = @gatekeeper.role_for(organization, @user)

  if no_access
    expect(role).to_not eq(role_str.to_sym)
  else
    expect(role).to eq(role_str.to_sym)
  end
end

Then(/^the only accessible organizations for the user are: (.*?)$/) do |org_names|
  expected_orgs = org_names.split(',')
                           .map { |fragment| fragment.split('"')[1] }
                           .map { |name| @org_names.fetch(name) }
  actual_orgs = @gatekeeper.accessible(@user)

  expected_orgs.each do |org|
    expect(actual_orgs).to include(org)
  end
  expect(actual_orgs.size).to eq(expected_orgs.size)
end
