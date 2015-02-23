Feature: Motivating kata feature

  Background:
    Given a user with an organizational chart with root "Root Org"
    And the organization "Org 1" is nested under "Root Org"
    And the organization "Child Org 1" is nested under "Org 1"
    And the organization "Child Org 2" is nested under "Org 1"

  Scenario: Child organization inherits user role
    When the user is granted admin access to "Org 1"
    And the user is denied access to "Child Org 2"
    Then the user should have admin access to "Child Org 1"
    And the user should not have admin access to "Child Org 2"

  Scenario: User only sees accessible organizations
    When the user is granted admin access to "Org 1"
    And the user is denied access to "Child Org 2"
    Then the only accessible organizations for the user are: "Org 1", "Child Org 1"
