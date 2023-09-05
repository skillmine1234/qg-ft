# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :nach_member do
    sequence(:iin) {|n| "%04i" % "#{n}"}
    is_enabled 'Y'
    name 'MyString'
    lock_version 1
    approval_status 'U'
    last_action 'C'
    approved_version 1
  end
end