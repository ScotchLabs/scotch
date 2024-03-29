FactoryGirl.define do
  factory :user do
    first_name "Stephen"
    last_name "Schwartz"
    sequence(:andrewid) {|n| "stephen#{n}"}
    password "schwartz"
    password_confirmation "schwartz"
    home_college "CFA"
    graduation_year "1968"
    smc "1337"
    gender "Male"
    residence "Morewood E"
    birthday Date.new(1948, 3, 6)
    majors "Drama"
    minors "Musical Composition"
    other_activities "Broadway"
    about "I am awesome"
    tech_skills "Being awesome"
    phone "4125555555"
  end

  factory :group do
    name "New Group"
    description "A new group"
    type "Group"
    sequence(:short_name) { |n| "newgroup#{n}" }
  end

  factory :board do
    name "Board of Directors"
    description "A new board"
    type "Board"
    sequence(:short_name) { |n| "newboard#{n}" }
  end

  factory :show do
    name "New Show"
    description "A new show"
    type "Show"
    sequence(:short_name) {|n| "show#{n}"}
    slot "Test Slot"
    price_with_id 5
    price_without_id 10
    location "McConomy Auditorium"
    tech_start Date.today + 5.days
    tech_end Date.today + 10.days
    writers "Stephen Schwartz"

    trait :tickets_available do
      tickets_available true
    end

    factory :available_show, traits: [:tickets_available]
  end

  factory :event do
    title "Production Meeting"
    association :owner, factory: :show
    start_time Time.now + 2.days
    end_time Time.now + 2.days + 1.hour
    location "UC303"
    description "Meeting of Production Staff"
    event_type "meeting"
    session "none"

    factory :performance do
      event_type 'show'
      max_attendance 100

      trait :tickets_available do
        association :owner, factory: :available_show
      end

      factory :open_performance, traits: [:tickets_available]
    end

    factory :audition do
      event_type 'audition'
    end
  end

  factory :contact do
    protocol "email"
    sequence(:address) {|n| "example#{n}@example.com"}
    temporary_name "Stephen Sondheim"
  end

  factory :ticket_reservation do
    association :event, factory: :open_performance
    association :owner, factory: :contact
    amount 1
    with_id true
  end

  factory :role do
    name "Member"
    group_type "Group"

    factory :show_role do
      group_type "Show"
    end
  end

  factory :position do
    association :group
    association :role
    association :user
    display_name "New Position"

    factory :show_position do
      association :group, factory: :show
      association :role, factory: :show_role
    end
  end
end
