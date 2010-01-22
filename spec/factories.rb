Factory.define :user do |u|
  u.sequence(:name) { |a| "user#{a}" }
  u.email { |a| "#{a.name}@mailinator.com" }
  u.password { |a| "pass_#{a.name}" }
  u.password_confirmation { |a| a.password }
end

Factory.define :owner, :class => :owner, :parent => :user do |o|
  o.sequence(:name) { |s| "owner#{s}" }
  o.plan "trial"
end

Factory.define :editor, :class => :editor, :parent => :user do |e|
  e.sequence(:name) { |s| "editor#{s}" }
  e.owner { |e| e.association(:owner) }
end

Factory.define :site do |s|
  s.sequence(:name) { |s| "site#{s}" }
  s.server { |s| "ftp.#{s.name}.com" }
  s.site_root { |s| "/var/www/#{s.name}" }
  s.site_url { |s| "www.{s.name}.com" }
  s.login { |s| s.name }
  s.password { |s| s.login }
  s.owner { |s| s.association(:owner) }
end

Factory.define :page do |p|
  p.sequence(:path) { |p| "#{p}.html" }
  p.site { |p| p.association(:site) }
end

Factory.define :card , :class => CreditCard do |c|
  c.first_name 'John'
  c.last_name 'Doe'
  c.number '1'
  c.year 2015
  c.month 1
end
