FactoryGirl.define do
  factory :user do
    first_name "Stephen"
    last_name "Schwartz"
    andrewid "stephen"
    password "schwartz"
    password_confirmation "schwartz"
    home_college "CFA"
    graduation_year Date.today.year + 4
    smc "1337"
    gender "Male"
    residence "Morewood E"
    birthday Date.new(1948, 3, 6)
    majors "Drama"
    minors "Musical Composition"
    other_activities "Broadway"
    about "I am awesome"
    tech_skills "Being awesome"
  end
end
