# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ft_purpose_code do
    sequence(:code) {|n| "%04i" % "#{n}"}
    description "MyString"
    is_enabled "MyString"
    allow_only_registered_bene "1"
    created_by {Factory(:user).id}
    updated_by {Factory(:user).id}
    lock_version 1
    approval_status "U"
    last_action "C"
    approved_version 1
  end
end