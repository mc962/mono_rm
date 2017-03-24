require 'pry'

require_relative '../config/model_loader'
ENV['DATABASE_URL'] ||= "postgres://localhost/dragons"

load_models
binding.pry
