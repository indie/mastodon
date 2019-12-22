

# Apache2 and the Return of the ECOSTEADER Mastodon

REQUIRED:  Apache2 

Set up your localhost environment to develop and backup your custom Mastodon instance. This 
fork of Mastodon does NOT use third-party malware, like EVIL SALESFORCE's Heroku or Docker 
(which writes endless logs and ups your server costs; most of Docker is PLAGIARIZED from 
unpaid or underpaid technical writers by people who do not understand Linux 
systems.) 

Please don't do that here. 

## Get started

Configure your SSH on GitHub. This tutorial assumes you have already configured SSH keys with 
your GitHub account. Then start your own branch so you can track your own changes. This guide 
has been tested and works on Ubuntu 18.10, but your system may be different.

    git clone git@github.com:indie/mastodon.git 
    cd mastodon && git checkout ecosteaderfx_2.8_master 
    git pull 
    git checkout branch your_branch_name 

Configure your Ruby on Rails development environment to let `rbenv` manage your ruby builds; upstream 
are pretty good about keeping master RUBIES secure.  Note Heroku's use of [nginx is permanantly insecure].

    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    cd ~/.rbenv && src/configure && make -C src

Tell your `.profile` directory to find the rbenv at `~/.rbenv`. There are at least a couple of ways
to do this:

    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc

Or edit the `~/.bashrc` directly to append the $PATH with a colon and the location of the rbenv build, 
and SOURCE the newly-updated file

    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    SOURCE ~/.bashrc

Now build the plugins directory
    
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build


The first dependencies we add are for SSL: 

    sudo apt-get install -y libssl-dev libreadline-dev

Now the 2.6.1 rubies should install without problem. Note that if you are not creating a development 
environment, and instead are building directly on the prod server, you might also want to add the 
`RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install 2.6.1` as the jemalloc can help reduce memory 
usage on production systems. 
    
    rbenv install 2.6.1

Get your postgres going; here we also add a client lib. Then you can log-in and check that it 
works; as per standard postgres, use `\q` to exit.
    
    sudo apt install postgresql postgresql-contrib libpq-dev
    sudo -u postgres psql
    psql (10.8 (Ubuntu 10.8-0ubuntu0.18.10.1))
     Type "help" for help.

     postgres=# \q

Time to install the _GNU IDN library_ developer package; this belongs at a system location, where 
it can do the most good. 

     sudo apt install libidn11-dev

Finally are we ready to run `bundle install`. Be sure you're at the root of the cloned `mastodon` directory, and on 
your own branch. If you followed ths guide on a true Linux system, you should see SUCCESS: 

     bundle install 

  Success!  

     Bundle complete! 117 Gemfile dependencies, 269 gems now installed.
     Use `bundle info [gemname]` to see where a bundled gem is installed.


To build a local development environment that actually runs Mastodon like it will be on a production server, a user named 
`mastodon` needs to exist; let's set that up with your postgres:

     $ sudo -u postgres psql
     psql (10.8 (Ubuntu 10.8-0ubuntu0.18.10.1))
     Type "help" for help.

     postgres=# CREATE USER mastodon CREATEDB;
     CREATE ROLE
     postgres=# \q
 
The good news is that now we have all the basics ready to start running an _informational_ Mastodon 
instance. You can start building a custom theme around your topic-based content and have all the 
pieces in place so that when you're ready to start collaborating with other like-minded instances or 
users, it should be fairly straightforward.

## Options for "streaming" APIs

The next step is to get the high-level "streaming" APIs configured, and this can go many ways. If you 
find yourself getting stuck after following some overly complex "instruction", it's usually better 
to start removing Gems, rather than adding. It's always a good idea to watch out for code bloat 
and third-party things that are not clear on what they are doing to your system. There are many 
malicious actors that want to destroy what we're building; don't let them! 


### NodeJS & Yarn vs RageQuit

This is where things can get tricky. 

The long and short of this is: some webhosts, like AWS or Heroku, absolutely want you to push 
traffic through bottlenecks they can slow down; this is how they make money or attempt to "justify" 
putting your site on some sort of convoluted metered system (Linode's switch to "hourly" 
billing that destroyed Ecosteader's original Mastodon instance, for example). Heroku actually 
steals your data! It can be especially dangerous when those same webhosts actually target their 
own customers with malware and bots that throttle the true content of an instance as a means to 
exploit a customer's thriftiness.

[RageQuit](https://github.com/tootsuite/ragequit) is another option to modify the default NGINX 
frontend configs for Mastodon streaming; it calls itself "A WIP blazingly fast drop-in replacement 
for the Mastodon streaming api server."


### The good news

Since we're running an Apache2 (2.4.18) frontend that has been thoroughly tested and "works", the 
good news is that we have plenty of options that don't involve noisy Nginx. The NodeJS/Yarn config 
**will** work with a few minor adjustments to the `tootsuite/mastodon` default code as long as we 
don't implement anything on the NGINX side. We won't dig too much into those changes, but they are 
readily available in the `ecosteaderfx_2.8_master` repo, which you should already have cloned to 
your development machine.

Backup your production (copy) scripts and code: 

    pg_dump -Fc -U postgres mastodon_production > db_dec22_2019.dump


## Prepare environment for streaming

This guide explains how to build a streaming API manager on your `localhost`, so you can easily 
adjust configs (or delete default configs) on a remote production or test mirror.

Install Redis

    sudo apt install redis-server redis-tools

Install system-managed dependencies for Yarn (as sudo): 

    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
    sudo apt-get install yarn
   
To set-up a new database 

    bundle exec rails db:setup

OR To restore an old or "backup" database locally, first create a place for it to be restored in postgres:

   $ sudo -u postgres psql
     psql (10.8 (Ubuntu 10.8-0ubuntu0.18.10.1))
     Type "help" for help.

     postgres=# create database mastodon_development with owner mastod;
     CREATE DATABASE
     postgres=# \q

Then run `pg_restore` 

    sudo -u postgres pg_restore -U postgres -d mastodon_development -v ~/backups/prod_0120_2019.dump

Lastly, 

    bundle install
    yarn install --pure-lockfile --ignore-optional
    RAILS_ENV=production bundle exec rails assets:precompile #Omit the RAILS_ENV if you are building locally
    RAILS_ENV=production bundle exec rails db:migrate  #Omit the RAILS_ENV if you are building locally
    rails s  #For local testing
    
    
-----------------    
    
 (Additional notes on UPGRADING PostGRES including some .jp-friendly help):  
 
    dpkg -l | grep postgresql

#Mastodon を止める

    systemctl stop mastodon-{web,sidekiq,streaming}.service

#まず PostgreSQL のリポジトリを追加して、アップデートする

    sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    sudo apt update

#今回は PostgreSQL 10 にするのでバージョンを指定してインストール

    sudo apt install postgresql-10 postgresql-client-10 postgresql-contrib-10`


#インストールされたか確認、下記をすると今インストールされているものが出る

    dpkg -l | grep postgresql`


#下記のような表示で、両方入った状態が確認できるはず

    postgresql
    postgresql-9.5
    postgresql-10
    postgresql-client-9.5
    postgresql-client-10
    postgresql-client-common
    postgresql-common
    postgresql-contrib
    postgresql-contrib-9.5```

#確認したら下記をしてクラスタを確認

    pg_lsclusters`

#下記のように 2 つの PostgreSQL が見えるはず

    Ver Cluster Port Status Owner    Data directory               Log file
    9.5 main    5432 online postgres /var/lib/postgresql/9.5/main /var/log/postgresql/postgresql-9.5-main.log
    10  main    5433 online postgres /var/lib/postgresql/10/main /var/log/postgresql/postgresql-10-main.log```

#このときは 10 の接続先が 5433 になっていて、まだ 9.5 が通常ポートの 5432 につながった状態

#次にインストール先の 10 を止めて、PostgreSQL もとめてアップグレード開始

    sudo pg_dropcluster 10 main --stop
    sudo service postgresql stop
    sudo pg_upgradecluster 9.5 main


#何もエラーが出なければ DB の移行がはじまる。まあまあ時間かかる。(うちではエラーでなかったのでどんなエラー出るかはわかりません)

#終わったら再度確認  `pg_lsclusters`

#すると 10 のほうがポートが 5432 になっているはず
    
    Ver Cluster Port Status  Owner    Data directory               Log file
    9.5 main    5433 offline postgres /var/lib/postgresql/9.5/main /var/log/postgresql/postgresql-9.5-main.log
    10  main    5432 offline postgres /var/lib/postgresql/10/main /var/log/postgresql/postgresql-10-main.log```

#PostgreSQL を再起動してバージョンが 10 になっているか確認

    sudo service postgresql restart
    psql --version

#9.5 を削除

    sudo pg_dropcluster 9.5 main`

#最後に Mastodon をリスタート

    systemctl restart mastodon-{web,sidekiq,streaming}.service`


[nginx is permanantly insecure]:https://www.zdnet.com/article/russian-police-raid-nginx-moscow-office/
