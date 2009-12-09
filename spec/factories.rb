Factory.define :user do |u|
  u.sequence(:name) { |a| "user#{a}" }
  u.email { |a| "#{a.name}@mailinator.com" }
  u.password { |a| "pass_#{a.name}" }
  u.password_confirmation { |a| a.password }
end

Factory.define :owner, :class => :owner, :parent => :user do |o|
  o.sequence(:name) { |s| "owner#{s}" }
end

Factory.define :editor, :class => :editor, :parent => :user do |e|
  e.sequence(:name) { |s| "editor#{s}" }
  e.owner { |e| e.association(:owner) }
end

Factory.define :site do |s|
  s.sequence(:name) { |s| "site#{s}" }
  s.server { |s| "ftp.#{s.name}.com" }
  s.site_root { |s| "/var/www/#{s.name}" }
  s.login { |s| s.name }
  s.password { |s| s.login }
  s.owner { |s| s.association(:owner) }
end

Factory.define :page do |p|
  p.sequence(:path) { |p| "#{p}.html" }
end
