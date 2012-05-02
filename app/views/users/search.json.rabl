collection @users

node(:label) {|user| user.name }
node(:value) {|user| user.andrewid }