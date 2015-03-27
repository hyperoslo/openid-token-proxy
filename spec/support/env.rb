def stub_env(name, value)
  allow(ENV).to receive(:[]).with(anything)
  allow(ENV).to receive(:[]).with(name).and_return(value)
end
