
# Mastodon Fediverse servers with Apache2 
# Localize your stream

## 

Set up your localhost environment to develop and backup your custom Mastodon instance. 

### Apache not nginx -- remove to eliminate potential conflicts 

    sudo apt remove nginx
    sudo apt --purge remove nginx/
    sudo apt --purge remove nginx 

## Get started

        

    git clone git@github.com:indie/mastodon.git 
    cd mastodon && git checkout ecosteader_v3.3
    git pull 
    git checkout branch your_branch_name 

System-based install prerequisites:

    sudo apt install autoconf bison build-essential zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev
    apache2 node-cacache libmemcached-dev libnss-cache


Configure your Ruby on Rails development environment to let `rbenv` manage your ruby builds; upstream 
are pretty good about keeping master RUBIES secure.  Note Heroku's use of [nginx is permanantly insecure].

    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc

Configure for rbenv to load automatically, and check with `type rbenv`:

    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    source ~/.bashrc
    type rbenv

Now build the plugins directory
    
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    rbenv install -l
    rbenv install 2.6.5
    rbenv global 2.6.5
    cd mastodon
    gem install bundler:2.1.2

Note that if you are not creating a development environment, and instead are building 
directly on the prod server, you might also want to add the `RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install 2.6.5` 
as the jemalloc can help reduce memory usage on production systems. 
    
The next dependencies we add are for SSL: 

    sudo apt install -y libssl-dev libyaml-dev libreadline6-dev libicu-dev

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

    bundle update --bundler
    bundle install

Success!

     Bundle complete! 117 Gemfile dependencies, 269 gems now installed.
     Use `bundle info [gemname]` to see where a bundled gem is installed.
     
 
To build a local development environment that actually runs Mastodon like it will be on a 
production server, a user named `mastodon` needs to exist; let's set that up with your postgres:

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


Finally, confirm you have a recent version. 


## Migrating a database from nginx to Apache server

Backup your production (copy) scripts and code: 

    pg_dump -Fc -U postgres mastodon_production > backupt’ąątsoh_015.2021.dump


## Prepare environment for streaming

This guide explains how to build a streaming API manager on your `localhost`, so you can easily 
adjust configs (or delete default configs) on a remote production or test mirror.

Start Apache2: 

    sudo systemctl apache2 [start / status]

Install Redis

    sudo apt install redis-server redis-tools

Check your version of node ([node install directions] not included)

    node --version 
    v12.16.3

Install the at least the minimum required [version of nodejs]

    nodejs --version
    v14.2.0

Check if system yarn exists, is old, needs updated, etc 

     ls -al /usr/bin/yarn 
                   20734 Feb 23  2018
     rm -rf /usr/bin/yarn

Install yarn via npm, and symbolically link to default 
    npm install -g yarn
    sudo ln -s /usr/local/bin/yarn /usr/bin/yarn

   
To set-up a new database 

    bundle exec rails db:setup

OR To restore an old or "backup" database locally, first create a place for it to be restored in postgres:

     sudo -u postgres psql
     psql (10.8 (Ubuntu 10.8-0ubuntu0.18.10.1))
     Type "help" for help.

     postgres=# create database mastodon_development with owner mastodon;
     CREATE DATABASE
     postgres=# \q

Then run `pg_restore` 

    sudo -u postgres pg_restore -U postgres -d mastodon_development -v /backups/backup_18May2021.dump
    bin/rails db:schema:load RAILS_ENV=development  #may be needed depending on your configs
    bin/rails db:migrate RAILS_ENV=development

Optional alternative commands for production system replication:

    bundle install
    yarn install --pure-lockfile --ignore-optional
    RAILS_ENV=production bundle exec rails assets:precompile #Omit the RAILS_ENV if you are building locally
    RAILS_ENV=production bundle exec rails db:migrate  #Omit the RAILS_ENV if you are building locally
    rails s  #For local testing
    
    
-----------------    
    
 (Additional notes on UPGRADING PostGRES including some :100: .jp-friendly help):  
 
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

    systemctl restart mastodon-{web,sidekiq,streaming}.service



## Miscellaneous admin tips for remote server mgmt:

SSH remote key timeout OpenSSH>=7.2
    ssh -o AddKeysToAgent=yes you@yourhostname "whazzup"
    ssh you@yourhostname 

[pgbouncer] is a PostgreSQL connection pooler. Any target application can be connected to 
pgbouncer as if it were a PostgreSQL server, and pgbouncer will create a connection to the 
actual server, or it will reuse one of its existing connections. The aim of pgbouncer is 
to lower the performance impact of opening new connections to PostgreSQL, which can help 
your server. pgBouncer is a transparent proxy for PostgreSQL that provides pooling based on database transactions, rather than sessions. That has the benefit that a real database connection is not needlessly occupied while a thread is doing nothing with it. Mastodon supports pgBouncer, you simply need to connect to it instead of PostgreSQL, and set the environment variable PREPARED_STATEMENTS=false


[node install directions]: https://github.com/nodejs/node/blob/master/BUILDING.md
[version of nodejs]: https://github.com/nodesource/distributions#installation-instructions
[nginx is permanantly insecure]:https://www.zdnet.com/article/russian-police-raid-nginx-moscow-office/
[RageQuit]:https://github.com/tootsuite/ragequit
[pgbouncer]: http://www.pgbouncer.org/usage.html#quick-start
