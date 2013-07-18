#!/usr/bin/env bash

function setup_rvm(){

	if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
	    # First try to load from a user install
	    source "$HOME/.rvm/scripts/rvm"
	elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
	    # Then try to load from a root install
	    source "/usr/local/rvm/scripts/rvm"
	else
	    printf "No RVM installation found. Installing..."
	    dir_cur=$PWD
	    cd /home/vagrant
		\curl -L --silent -- show-error https://get.rvm.io | bash -s stable
		cd $dir_cur
		printf " Done!"

		setup_rvm
	fi
}

cd /vagrant


printf "Installing required packages with apt-get..."

# suppress MySQL root password prompt
# NOTE: this leaves the MySQL root user password blank!
export DEBIAN_FRONTEND=noninteractive 
apt-get update > /dev/null
apt-get install -qq -y curl libmysqlclient-dev git make gawk g++ libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev mysql-server

printf "Done! Package installation successful."


mysql -u root < provision_mysql

setup_rvm
rvm install 1.9.3 > /dev/null
rvm use 1.9.3 --default

# If project has a Gemfile make use of it 
if [[ -s "./Gemfile" ]] ; then
    printf "Running 'bundle install' against Gemfile"
   	# Must install to vendor/cache because bundler
    # buggers install of carlosdp/mail otherwise
    bundle install --path vendor/cache > /dev/null
else
	printf "No Gemfile found in $PWD. Continuing happily."
fi

# Set up development database
gunzip db/data.yml.gz 
rake db:setup

echo "Provisioning complete."