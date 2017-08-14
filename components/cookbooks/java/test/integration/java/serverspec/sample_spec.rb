require 'spec_helper'

describe command('echo "test"') do
  its(:exit_status) { should eq 0 }
end

