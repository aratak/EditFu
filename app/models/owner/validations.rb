class Owner

  attr_accessible :domain_name, :company_name, :terms_of_service

  validates_presence_of  :domain_name #, :plan
  validates_associated :plan 
  # validates_presence_of :company_name
  validates_length_of :company_name, :within => 3..255, :allow_blank => true
  validates_uniqueness_of :domain_name
  validates_format_of :domain_name, :with => /^\w+$/
  validates_exclusion_of :domain_name, :in => %w(www admin dev staging)

  validates_acceptance_of :terms_of_service, :on => :create, :allow_nil => false, :message => 'Read and accept it!'
  
end