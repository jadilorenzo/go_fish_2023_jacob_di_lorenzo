# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { 'Default' }
    last_name { 'User' }
    sequence :email do |n|
      "person#{n}@example.com"
    end

    password { 'password123' }
    password_confirmation { password }

    trait :regular_user do
      first_name { 'Regular' }
      last_name { 'User' }
      role { User.roles[:user] }
    end

    trait :admin do
      first_name { 'Org' }
      last_name { 'Admin' }
      role { User.roles[:admin] }
    end

    trait :super_admin do
      first_name { 'Support' }
      last_name { 'Admin' }
      super_admin { true }
    end
  end
end
