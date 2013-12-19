collection @users
attributes :id, :name, :first_name, :last_name, :andrewid, :email,
:phone, :home_college, :graduation_year, :smc, :gender, :residence,
:birthday, :majors, :minors, :other_activities, :about, :tech_skills

node(:thumbnail) { |user| user.headshot(:thumb) }
node(:link) { |user| user_path(user) }

