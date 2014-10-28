require_relative '../lib/sample'
describe "Sanity check to confirm rspec is set up properly." do
  it "should return the sample" do
    mysample = Sample.new "mysample"
    expect(mysample.sample).to eq "mysample"
  end
end
