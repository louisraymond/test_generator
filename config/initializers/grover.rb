Grover.configure do |config|
  config.options = {
    launch_args: ['--no-sandbox', '--disable-setuid-sandbox'],
    wait_until: 'domcontentloaded'
  }
end
