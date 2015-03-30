def stub_env(name, value = nil)
  allow(ENV).to receive(:[]).with(anything)
  allow(ENV).to receive(:[]).with(name).and_return(value)
end
