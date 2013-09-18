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

  factory :group do
    name "New Group"
    description "A new group"
    type "Group"
    short_name "newgroup"

    factory :board do
      name "Board of Directors"
      type "Board"
      short_name "board"
    end

    factory :show do
      name "New Show"
      type "Show"
      short_name "show"
      slot "Test Slot"
      price_with_id 5
      price_without_id 10
      location "McConomy Auditorium"
      tech_start Date.today + 5.days
      tech_end Date.today + 10.days
      writers "Stephen Schwartz"
    end
  end
end
