def load_models
  dir = File.dirname(__FILE__)
  models_directory = File.join(dir, '..', "/test_models")

  model_files = Dir["#{models_directory}/*.rb"]
  model_files.each do |file|
    require_relative file
  end
end
