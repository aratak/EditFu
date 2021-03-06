Factory.define :user do |u|
  u.sequence(:user_name) { |a| "user#{a}" }
  u.email { |a| "#{a.user_name}@mailinator.com" }
  u.password { |a| "pass_#{a.user_name}" }
  u.password_confirmation { |a| a.password }
end

Factory.define :owner, :class => :owner, :parent => :user do |o|
  o.sequence(:user_name) { |s| "owner#{s}" }
  o.sequence(:company_name) { |s| "Domain#{s}" }
  o.sequence(:domain_name) { |s| "domain_#{s}" }
  o.plan Plan::TRIAL
  o.terms_of_service "1"
end

Factory.define :free_owner, :class => :owner, :parent => :user do |o|
  o.sequence(:user_name) { |s| "free_owner#{s}" }
  o.sequence(:company_name) { |s| "Free Domain #{s}" }
  o.plan Plan::FREE
  o.terms_of_service "1"
end

Factory.define :editor, :class => :editor, :parent => :user do |e|
  e.sequence(:user_name) { |s| "editor#{s}" }
  e.owner { |e| e.association(:owner) }
end

Factory.define :site do |s|
  s.sequence(:name) { |s| "site#{s}" }
  s.server { |s| "ftp.#{s.name}.com" }
  s.site_root { |s| "/var/www/#{s.name}" }
  s.site_url { |s| "www.#{s.name}.com" }
  s.login { |s| s.name }
  s.password { |s| s.login }
  s.owner { |s| s.association(:owner) }
end

Factory.define :page do |p|
  p.sequence(:path) { |p| "#{p}.html" }
  p.site { |p| p.association(:site) }
end

Factory.define :card do |c|
  c.first_name 'John'
  c.last_name 'Doe'
  c.number '1'
  c.zip '12345'
  c.verification_value '1'
  c.display_expiration_date '01-01-2030'.to_date
  c.association :owner
end

Factory.define :subscription do |s|
  s.starts_at Time.now
  s.ends_at 1.month.from_now.to_date
  s.price 300
  s.plan Plan::FREE
  
  s.association :owner
end

# Factory.define :card , :class => ExtCreditCard do |c|
#   c.first_name 'John'
#   c.last_name 'Doe'
#   c.number '1'
#   c.zip '12345'
#   c.verification_value '1'
#   c.expiration '01/2030'
# end

