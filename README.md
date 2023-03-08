# Description
Famous game ***"Who Wants to Be a Millionaire?"***. If you wish to have some nostalgia - just install this game on your PC, play and have fun! 

## Supported features
- Registration&Authorization ([**Devise**](https://github.com/heartcombo/devise))
- Admin (to upload new questions/answers)

## Setup
1. Required Ruby (v. 3.1.2) & Rails (v. 7) installed on your PC.
2. Clone application to local PC:
```
git clone git@github.com:Godlikefreq/khsm.git
```
4. Run
```
bundle install
```

### Database setup
1. To specify database name, adapter and other parameters for different scopes change it in `config/database.yml`. 
Default DB adapter is **PostgreSQL** ([**Install PostgreSQL on Ubuntu 20.04**](https://www.digitalocean.com/community/tutorials/how-to-install-postgresql-on-ubuntu-20-04-quickstart#step-1-installing-postgresql)).
2. Make new database ([**Create DB in PostgreSQL**](https://www.digitalocean.com/community/tutorials/how-to-install-postgresql-on-ubuntu-20-04-quickstart#step-4-creating-a-new-database)).
3. Run
```
bundle exec rails db:migrate
```

## Run locally
1. To run application on your local machine run following command in console:
```
rails s
```
2. Open `http://localhost:3000/` in your browser.

## Upload new questions
1. Create new user ([**Registration URL**](http://localhost:3000/users/sign_up))
2. Make user admin:
  - open console in app's folder
  ```
  rails c
  ```
  - find your recently created user:
  ```ruby
  u = User.last
  ```
  - make user admin:
  ```ruby
  u.is_admin=true
  ```
  - open admin's panel and upload new questions ([**Questions uploading URL**](http://localhost:3000/admin/question))
 
## Sources
- Powered with [**Bootstrap 5**](https://getbootstrap.com/docs/5.0/getting-started/introduction/)
- Made and tested on **Ruby 3.1.2** & **Rails 7**
