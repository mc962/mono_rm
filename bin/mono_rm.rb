require 'pry'
require_relative '../config/boot'

ENV['DATABASE_URL'] ||= "postgres://localhost/dragons"

load_db_adapter
load_models

binding.pry
