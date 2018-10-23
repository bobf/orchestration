namespace 'orchestration' do
  desc 'Initialise boilerplate for adding Docker to your application'
  task :orchestrate do
    Orchestration::InstallGenerator.start
  end
end
